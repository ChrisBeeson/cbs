use body_core::{BodyBus, BusError, Cell, Envelope};
use serde_json::json;
use std::env;
use std::process;
use std::sync::Arc;
use tokio;
use tokio::sync::RwLock;

// Import cells
use io_print_greeting_rs::PrinterCell;
use io_prompt_name_rs::PromptNameCell;
use logic_greet_rs::GreeterCell as LogicGreeterCell;

/// Configuration for the Body framework
#[derive(Debug, Clone)]
pub struct BodyConfig {
    pub nats_url: String,
    pub use_mock_bus: bool,
    pub demo_mode: bool,
}

impl Default for BodyConfig {
    fn default() -> Self {
        Self {
            nats_url: "nats://localhost:4222".to_string(),
            use_mock_bus: false,
            demo_mode: false,
        }
    }
}

impl BodyConfig {
    /// Load configuration from environment variables and command line args
    pub fn from_env_and_args() -> Self {
        let mut config = Self::default();
        
        // Check environment variables
        if let Ok(nats_url) = env::var("NATS_URL") {
            config.nats_url = nats_url;
        }
        
        if env::var("CBS_DEMO_MODE").is_ok() {
            config.demo_mode = true;
        }
        
        if env::var("CBS_MOCK_BUS").is_ok() {
            config.use_mock_bus = true;
        }
        
        // Check command line arguments
        let args: Vec<String> = env::args().collect();
        for (i, arg) in args.iter().enumerate() {
            match arg.as_str() {
                "--nats-url" => {
                    if let Some(url) = args.get(i + 1) {
                        config.nats_url = url.clone();
                    }
                }
                "--demo" => {
                    config.demo_mode = true;
                }
                "--mock-bus" => {
                    config.use_mock_bus = true;
                }
                "--help" | "-h" => {
                    print_help();
                    process::exit(0);
                }
                _ => {}
            }
        }
        
        config
    }
}

/// Print help message
fn print_help() {
    println!("Cell Body System (CBS) - MVP Demo");
    println!();
    println!("USAGE:");
    println!("    body [OPTIONS]");
    println!();
    println!("OPTIONS:");
    println!("    --nats-url <URL>    NATS server URL (default: nats://localhost:4222)");
    println!("    --demo              Run in demo mode with simulated input");
    println!("    --mock-bus          Use mock bus instead of NATS (for testing)");
    println!("    -h, --help          Print this help message");
    println!();
    println!("ENVIRONMENT VARIABLES:");
    println!("    NATS_URL           NATS server URL");
    println!("    CBS_DEMO_MODE      Enable demo mode");
    println!("    CBS_MOCK_BUS       Use mock bus");
}

/// Mock bus implementation for testing without NATS
pub struct MockBus {
    handlers: Arc<RwLock<std::collections::HashMap<String, body_core::MessageHandler>>>,
}

impl MockBus {
    pub fn new() -> Self {
        Self {
            handlers: Arc::new(RwLock::new(std::collections::HashMap::new())),
        }
    }
}

#[async_trait::async_trait]
impl BodyBus for MockBus {
    async fn request(&self, envelope: Envelope) -> Result<serde_json::Value, BusError> {
        let subject = envelope.subject();
        
        let handlers = self.handlers.read().await;
        if let Some(handler) = handlers.get(&subject) {
            handler(envelope)
        } else {
            Err(BusError::NotFound(format!("No handler for subject: {}", subject)))
        }
    }
    
    async fn subscribe(&self, subject: &str, handler: body_core::MessageHandler) -> Result<(), BusError> {
        let mut handlers = self.handlers.write().await;
        handlers.insert(subject.to_string(), handler);
        println!("MockBus: Subscribed to {}", subject);
        Ok(())
    }
}

/// Main Body orchestrator
pub struct Body {
    config: BodyConfig,
}

impl Body {
    pub fn new(config: BodyConfig) -> Self {
        Self { config }
    }
    
    /// Run the CBS demo flow
    pub async fn run_demo(&self) -> Result<(), Box<dyn std::error::Error>> {
        println!("🧬 Cell Body System (CBS) - MVP Demo");
        println!("=====================================");
        
        if self.config.demo_mode {
            self.run_demo_mode().await
        } else {
            self.run_interactive_mode().await
        }
    }
    
    /// Run in demo mode with simulated input
    async fn run_demo_mode(&self) -> Result<(), Box<dyn std::error::Error>> {
        println!("Running in demo mode...");
        
        // Simulate the three-cell flow
        println!("\n1. 📝 Prompting for name (simulated)...");
        let name = "Ada Lovelace";
        println!("   Input: {}", name);
        
        println!("\n2. 🤖 Processing greeting...");
        let _greeting_cell = LogicGreeterCell::new();
        let name_envelope = Envelope::new_request("greeter", "say_hello", "demo/v1/Name", json!({"name": name}));
        let greeting_result = LogicGreeterCell::handle_greeting_request(name_envelope)?;
        let greeting_message = greeting_result["message"].as_str().unwrap();
        println!("   Generated: {}", greeting_message);
        
        println!("\n3. 🖨️  Printing greeting...");
        let _printer_cell = PrinterCell::new();
        let print_envelope = Envelope::new_request("printer", "write", "demo/v1/Message", json!({"message": greeting_message}));
        PrinterCell::handle_print_request(print_envelope)?;
        
        println!("\n✅ Demo completed successfully!");
        Ok(())
    }
    
    /// Run in interactive mode with MockBus
    async fn run_interactive_mode(&self) -> Result<(), Box<dyn std::error::Error>> {
        println!("Running in interactive mode with MockBus...");
        
        // Create MockBus and register cells
        let bus = MockBus::new();
        
        println!("\n🔧 Registering cells...");
        let prompt_cell = PromptNameCell::new();
        let greeting_cell = LogicGreeterCell::new();
        let printer_cell = PrinterCell::new();
        
        prompt_cell.register(&bus).await?;
        greeting_cell.register(&bus).await?;
        printer_cell.register(&bus).await?;
        
        println!("\n1. 📝 Prompting for name...");
        let prompt_envelope = Envelope::new_request("prompt_name", "read", "demo/v1/Void", json!({}));
        let name_result = bus.request(prompt_envelope).await?;
        let name = name_result["name"].as_str().unwrap();
        
        println!("   Input: {}", name);
        
        println!("\n2. 🤖 Processing greeting...");
        let name_envelope = Envelope::new_request("greeter", "say_hello", "demo/v1/Name", json!({"name": name}));
        let greeting_result = bus.request(name_envelope).await?;
        let greeting_message = greeting_result["message"].as_str().unwrap();
        
        println!("   Generated: {}", greeting_message);
        
        println!("\n3. 🖨️  Printing greeting...");
        let print_envelope = Envelope::new_request("printer", "write", "demo/v1/Message", json!({"message": greeting_message}));
        bus.request(print_envelope).await?;
        
        println!("\n✅ Flow completed successfully via MockBus!");
        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = BodyConfig::from_env_and_args();
    
    println!("Configuration:");
    println!("  NATS URL: {}", config.nats_url);
    println!("  Demo Mode: {}", config.demo_mode);
    println!("  Mock Bus: {}", config.use_mock_bus);
    println!();
    
    let body = Body::new(config);
    body.run_demo().await
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn body_config_defaults() {
        let config = BodyConfig::default();
        assert_eq!(config.nats_url, "nats://localhost:4222");
        assert!(!config.use_mock_bus);
        assert!(!config.demo_mode);
    }
    
    #[test]
    fn body_config_from_env() {
        env::set_var("NATS_URL", "nats://test:4222");
        env::set_var("CBS_DEMO_MODE", "1");
        env::set_var("CBS_MOCK_BUS", "1");
        
        let config = BodyConfig::from_env_and_args();
        assert_eq!(config.nats_url, "nats://test:4222");
        assert!(config.demo_mode);
        assert!(config.use_mock_bus);
        
        // Clean up
        env::remove_var("NATS_URL");
        env::remove_var("CBS_DEMO_MODE");
        env::remove_var("CBS_MOCK_BUS");
    }
    
    #[tokio::test]
    async fn mock_bus_subscription() {
        let bus = MockBus::new();
        let handler = Box::new(|_env: Envelope| Ok(json!({"test": true})));
        
        let result = bus.subscribe("test.subject", handler).await;
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn mock_bus_request_with_handler() {
        let bus = MockBus::new();
        let handler = Box::new(|envelope: Envelope| {
            Ok(json!({"received": envelope.service}))
        });
        
        bus.subscribe("cbs.test.action", handler).await.unwrap();
        
        let envelope = Envelope::new_request("test", "action", "demo/v1/Test", json!({}));
        let result = bus.request(envelope).await.unwrap();
        
        assert_eq!(result["received"], "test");
    }
    
    #[tokio::test]
    async fn mock_bus_request_no_handler() {
        let bus = MockBus::new();
        let envelope = Envelope::new_request("test", "action", "demo/v1/Test", json!({}));
        
        let result = bus.request(envelope).await;
        assert!(result.is_err());
        
        match result.unwrap_err() {
            BusError::NotFound(msg) => assert!(msg.contains("No handler")),
            _ => panic!("Expected NotFound error"),
        }
    }
    
    #[test]
    fn body_creation() {
        let config = BodyConfig::default();
        let body = Body::new(config.clone());
        assert_eq!(body.config.nats_url, config.nats_url);
    }
}