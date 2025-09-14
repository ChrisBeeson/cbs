use std::fs;
use tempfile::TempDir;
use tokio::net::TcpListener;
use web_server::{WebServerCell, WebServerConfig};

#[tokio::test]
async fn test_static_file_serving() {
    // Create a temporary directory with test files
    let temp_dir = TempDir::new().unwrap();
    let temp_path = temp_dir.path();
    
    // Create test HTML file
    fs::write(
        temp_path.join("index.html"),
        r#"<!DOCTYPE html><html><body><h1>Test Page</h1></body></html>"#,
    ).unwrap();
    
    // Create test CSS file
    fs::create_dir_all(temp_path.join("css")).unwrap();
    fs::write(
        temp_path.join("css/style.css"),
        "body { background-color: #f0f0f0; }",
    ).unwrap();
    
    // Start web server
    let config = WebServerConfig {
        static_dir: temp_path.to_path_buf(),
        port: 0, // Use random available port
        enable_cors: true,
    };
    
    let server = WebServerCell::new(config);
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();
    
    // Start server in background
    tokio::spawn(async move {
        server.serve(listener).await.unwrap();
    });
    
    // Wait for server to start
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    
    // Test serving index.html
    let client = reqwest::Client::new();
    let response = client
        .get(&format!("http://{}/index.html", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    let body = response.text().await.unwrap();
    assert!(body.contains("Test Page"));
    
    // Test serving CSS file
    let response = client
        .get(&format!("http://{}/css/style.css", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    let body = response.text().await.unwrap();
    assert!(body.contains("background-color"));
    
    // Test 404 for non-existent file
    let response = client
        .get(&format!("http://{}/nonexistent.html", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 404);
}

#[tokio::test]
async fn test_health_check_endpoint() {
    let temp_dir = TempDir::new().unwrap();
    let config = WebServerConfig {
        static_dir: temp_dir.path().to_path_buf(),
        port: 0,
        enable_cors: true,
    };
    
    let server = WebServerCell::new(config);
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();
    
    tokio::spawn(async move {
        server.serve(listener).await.unwrap();
    });
    
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    
    let client = reqwest::Client::new();
    let response = client
        .get(&format!("http://{}/health", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    let body: serde_json::Value = response.json().await.unwrap();
    assert_eq!(body["status"], "healthy");
    assert!(body["timestamp"].is_string());
}

#[tokio::test]
async fn test_cors_headers() {
    let temp_dir = TempDir::new().unwrap();
    let config = WebServerConfig {
        static_dir: temp_dir.path().to_path_buf(),
        port: 0,
        enable_cors: true,
    };
    
    let server = WebServerCell::new(config);
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();
    
    tokio::spawn(async move {
        server.serve(listener).await.unwrap();
    });
    
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    
    let client = reqwest::Client::new();
    let response = client
        .get(&format!("http://{}/health", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    
    // Check CORS headers
    let headers = response.headers();
    assert!(headers.contains_key("access-control-allow-origin"));
}

#[tokio::test]
async fn test_flutter_web_build_serving() {
    // Create a mock Flutter web build structure
    let temp_dir = TempDir::new().unwrap();
    let temp_path = temp_dir.path();
    
    // Create main.dart.js (Flutter web output)
    fs::write(
        temp_path.join("main.dart.js"),
        "// Mock Flutter web JavaScript",
    ).unwrap();
    
    // Create flutter.js
    fs::write(
        temp_path.join("flutter.js"),
        "// Mock Flutter loader JavaScript",
    ).unwrap();
    
    // Create index.html
    fs::write(
        temp_path.join("index.html"),
        r#"<!DOCTYPE html>
<html>
<head><title>Flutter Web</title></head>
<body><div id="app-loading">Loading...</div></body>
</html>"#,
    ).unwrap();
    
    let config = WebServerConfig {
        static_dir: temp_path.to_path_buf(),
        port: 0,
        enable_cors: true,
    };
    
    let server = WebServerCell::new(config);
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();
    
    tokio::spawn(async move {
        server.serve(listener).await.unwrap();
    });
    
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    
    let client = reqwest::Client::new();
    
    // Test serving Flutter web assets
    let response = client
        .get(&format!("http://{}/main.dart.js", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    assert_eq!(
        response.headers().get("content-type").unwrap(),
        "text/javascript"
    );
    
    let response = client
        .get(&format!("http://{}/flutter.js", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    
    // Test serving index.html with proper content type
    let response = client
        .get(&format!("http://{}/", addr))
        .send()
        .await
        .unwrap();
    
    assert_eq!(response.status(), 200);
    assert_eq!(
        response.headers().get("content-type").unwrap(),
        "text/html; charset=utf-8"
    );
}
