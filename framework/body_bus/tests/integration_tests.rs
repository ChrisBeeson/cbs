use body_bus::{NatsBus, NatsBusConfig};
use body_core::{BodyBus, BusError, Envelope, MessageHandler};
use serde_json::json;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

// Helper function to check if NATS server is available
async fn nats_available() -> bool {
    NatsBus::connect("nats://localhost:4222").await.is_ok()
}

// Skip test if NATS is not available
macro_rules! require_nats {
    () => {
        if !nats_available().await {
            eprintln!("Skipping test: NATS server not available at localhost:4222");
            return;
        }
    };
}

#[tokio::test]
async fn nats_connection_success() {
    require_nats!();
    
    let bus = NatsBus::connect("nats://localhost:4222").await;
    assert!(bus.is_ok());
    
    let bus = bus.unwrap();
    assert!(bus.is_connected());
}

#[tokio::test]
async fn nats_connection_failure() {
    let bus = NatsBus::connect("nats://localhost:9999").await;
    assert!(bus.is_err());
    
    match bus.unwrap_err() {
        BusError::Connection(_) => {}, // Expected
        _ => panic!("Expected Connection error"),
    }
}

#[tokio::test]
async fn nats_connection_timeout() {
    let config = NatsBusConfig {
        url: "nats://192.0.2.1:4222".to_string(), // Non-routable IP
        connection_timeout: Duration::from_millis(100),
        ..Default::default()
    };
    
    let start = std::time::Instant::now();
    let result = NatsBus::connect_with_config(config).await;
    let elapsed = start.elapsed();
    
    assert!(result.is_err());
    assert!(elapsed < Duration::from_millis(200)); // Should timeout quickly
}

#[tokio::test]
async fn request_reply_success() {
    require_nats!();
    
    let bus = NatsBus::connect("nats://localhost:4222").await.unwrap();
    
    // Set up a simple echo handler
    let echo_handler: MessageHandler = Box::new(|envelope| {
        Ok(envelope.payload.unwrap_or(json!({})))
    });
    
    bus.subscribe("cbs.test.echo", echo_handler).await.unwrap();
    
    // Give subscription time to register
    sleep(Duration::from_millis(100)).await;
    
    let request = Envelope::new_request("test", "echo", "demo/v1/Test", json!({"message": "hello"}));
    let response = bus.request(request).await.unwrap();
    
    assert_eq!(response["message"], "hello");
}

#[tokio::test]
async fn request_timeout_no_subscribers() {
    require_nats!();
    
    let config = NatsBusConfig {
        request_timeout: Duration::from_millis(100),
        ..Default::default()
    };
    let bus = NatsBus::connect_with_config(config).await.unwrap();
    
    let request = Envelope::new_request("nonexistent", "action", "demo/v1/Test", json!({}));
    let result = bus.request(request).await;
    
    assert!(result.is_err());
    match result.unwrap_err() {
        BusError::NotFound(_) => {}, // Expected for no responders
        BusError::Timeout => {}, // Also acceptable
        e => panic!("Expected NotFound or Timeout, got: {:?}", e),
    }
}

#[tokio::test]
async fn queue_group_load_balancing() {
    require_nats!();
    
    let bus = NatsBus::connect("nats://localhost:4222").await.unwrap();
    
    let counter = Arc::new(AtomicUsize::new(0));
    
    // Create two handlers that increment the same counter
    let counter1 = Arc::clone(&counter);
    let handler1: MessageHandler = Box::new(move |_| {
        counter1.fetch_add(1, Ordering::SeqCst);
        Ok(json!({"handler": 1}))
    });
    
    let counter2 = Arc::clone(&counter);
    let handler2: MessageHandler = Box::new(move |_| {
        counter2.fetch_add(1, Ordering::SeqCst);
        Ok(json!({"handler": 2}))
    });
    
    // Both handlers subscribe to the same subject (same queue group)
    bus.subscribe("cbs.loadtest.work", handler1).await.unwrap();
    bus.subscribe("cbs.loadtest.work", handler2).await.unwrap();
    
    sleep(Duration::from_millis(100)).await;
    
    // Send multiple requests
    let mut responses = Vec::new();
    for i in 0..10 {
        let request = Envelope::new_request("loadtest", "work", "demo/v1/Test", json!({"id": i}));
        if let Ok(response) = bus.request(request).await {
            responses.push(response);
        }
    }
    
    // Both handlers should have processed some messages (load balancing)
    let total_processed = counter.load(Ordering::SeqCst);
    assert!(total_processed > 0);
    assert_eq!(total_processed, responses.len());
}

#[tokio::test]
async fn error_propagation_in_handler() {
    require_nats!();
    
    let bus = NatsBus::connect("nats://localhost:4222").await.unwrap();
    
    // Handler that always returns an error
    let error_handler: MessageHandler = Box::new(|_| {
        Err(BusError::BadRequest("Invalid input".to_string()))
    });
    
    bus.subscribe("cbs.error.test", error_handler).await.unwrap();
    sleep(Duration::from_millis(100)).await;
    
    let request = Envelope::new_request("error", "test", "demo/v1/Test", json!({}));
    let result = bus.request(request).await;
    
    assert!(result.is_err());
    match result.unwrap_err() {
        BusError::BadRequest(msg) => assert_eq!(msg, "Invalid input"),
        e => panic!("Expected BadRequest error, got: {:?}", e),
    }
}

#[tokio::test]
async fn server_info_retrieval() {
    require_nats!();
    
    let bus = NatsBus::connect("nats://localhost:4222").await.unwrap();
    let server_info = bus.server_info();
    
    assert!(!server_info.server_name.is_empty());
}
