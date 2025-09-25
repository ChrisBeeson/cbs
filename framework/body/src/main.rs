use body_core::{AppLoader, BodyBus, BusError, Envelope};
use serde_json::json;
use std::env;
use std::process;
use std::sync::Arc;
use tokio;
use tracing::{debug, error, info, warn};
use tracing_subscriber::{fmt, prelude::*, EnvFilter};
use tokio::sync::RwLock;

// Import web server for serving applications
use web_server;

/// Configuration for the Body framework
#[derive(Debug, Clone)]
pub struct BodyConfig {
    pub nats_url: String,
    pub use_mock_bus: bool,
    pub demo_mode: bool,
    pub app_name: Option<String>,
}

impl Default for BodyConfig {
    fn default() -> Self {
        Self {
            nats_url: "nats://localhost:4222".to_string(),
            use_mock_bus: false,
            demo_mode: false,
            app_name: None,
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
                "--app" => {
                    if let Some(app_name) = args.get(i + 1) {
                        config.app_name = Some(app_name.clone());
                    }
                }
                "--demo" => {
                    config.demo_mode = true;
                }
                "--mock-bus" => {
                    config.use_mock_bus = true;
                }
                "--list-apps" => {
                    list_applications();
                    process::exit(0);
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
    info!("Cell Body System (CBS) Framework");
    info!("");
    info!("USAGE:");
    info!("    body [OPTIONS]");
    info!("");
    info!("OPTIONS:");
    info!("    --app <NAME>        Load specific application from applications/ directory");
    info!("    --list-apps         List all available applications");
    info!("    --nats-url <URL>    NATS server URL (default: nats://localhost:4222)");
    info!("    --demo              Run in demo mode with simulated input");
    info!("    --mock-bus          Use mock bus instead of NATS (for testing)");
    info!("    -h, --help          Print this help message");
    info!("");
    info!("ENVIRONMENT VARIABLES:");
    info!("    NATS_URL           NATS server URL");
    info!("    CBS_DEMO_MODE      Enable demo mode");
    info!("    CBS_MOCK_BUS       Use mock bus");
    info!("");
    info!("EXAMPLES:");
    info!("    body --list-apps                    # List available applications");
    info!("    body --app cli_greeter              # Run CLI greeter application");
    info!("    body --app flutter_flow_web         # Run Flutter web application");
    info!("    body --app my_app --demo            # Run application in demo mode");
}

/// List available applications
fn list_applications() {
    info!("Scanning for CBS applications...");
    
    let app_loader = AppLoader::new("./applications");
    match app_loader.discover_applications() {
        Ok(apps) => {
            if apps.is_empty() {
                info!("No applications found in ./applications/");
                info!("Create your first application:");
                info!("mkdir -p applications/my_app/cells");
                info!("# Add app.yaml configuration");
            } else {
                info!("Available applications:");
                for app in apps {
                    info!(name = %app, "app");
                }
            }
        }
        Err(e) => {
            error!(error = %e, "Error discovering applications");
            info!("Make sure you're in a CBS project directory");
        }
    }
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
        info!(subject = %subject, "MockBus: Subscribed");
        Ok(())
    }
}

/// Main Body orchestrator
pub struct Body {
    config: BodyConfig,
    app_loader: AppLoader,
}

impl Body {
    pub fn new(config: BodyConfig) -> Self {
        let app_loader = AppLoader::new("./applications");
        Self { config, app_loader }
    }
    
    /// Run the CBS framework
    pub async fn run(&self) -> Result<(), Box<dyn std::error::Error>> {
        info!("🧬 Cell Body System (CBS) Framework");
        info!("====================================");
        
        // Handle application loading if --app parameter provided
        if let Some(app_name) = &self.config.app_name {
            self.run_application(app_name).await
        } else {
            error!("No application specified");
            info!("Use --app <name> to run an application");
            info!("Use --list-apps to see available applications");
            info!("Use --help for more options");
            process::exit(1);
        }
    }
    
    /// Run a specific application
    async fn run_application(&self, app_name: &str) -> Result<(), Box<dyn std::error::Error>> {
        info!(app = app_name, "Loading application");
        
        // Discover available applications
        let available_apps = self.app_loader.discover_applications()?;
        
        if !available_apps.contains(&app_name.to_string()) {
            return Err(format!("Application '{}' not found. Available: {:?}", app_name, available_apps).into());
        }
        
        // Load application configuration
        let app_config = self.app_loader.load_application(app_name)?;
        info!(name = %app_config.name, version = %app_config.version, desc = %app_config.description, cells = app_config.cells.len(), shared = app_config.shared_cells.len(), "Loaded application config");
        
        // Determine application type based on name or configuration
        // This is a simple heuristic - in the future, app.yaml should include type
        if app_name.contains("web") || app_name.contains("flutter") {
            self.run_web_application(&app_config).await
        } else if app_name.contains("cli") || app_name.contains("greeter") {
            self.run_cli_application(&app_config).await
        } else {
            self.run_service_application(&app_config).await
        }
    }
    
    /// Run a web application
    async fn run_web_application(&self, app_config: &body_core::AppConfig) -> Result<(), Box<dyn std::error::Error>> {
        info!(name = %app_config.name, "Starting Web Application");
        
        // Set up web server configuration
        let web_dir = format!("./applications/{}/web", app_config.name);
        let web_config = web_server::WebServerConfig {
            static_dir: std::path::PathBuf::from(&web_dir),
            port: 8080,
            enable_cors: true,
        };
        
        let web_server_cell = web_server::WebServerCell::new(web_config);
        
        info!(path = %web_dir, "Serving static files from");
        info!("Starting web server on http://localhost:8080");
        
        // Start the web server
        let listener = tokio::net::TcpListener::bind("127.0.0.1:8080").await?;
        info!(name = %app_config.name, "Web application is running");
        info!("Open your browser to: http://localhost:8080");
        info!("Press Ctrl+C to stop");
        
        web_server_cell.serve(listener).await?;
        
        Ok(())
    }
    
    /// Run a CLI application
    async fn run_cli_application(&self, app_config: &body_core::AppConfig) -> Result<(), Box<dyn std::error::Error>> {
        info!(name = %app_config.name, "Starting CLI Application");
        
        if self.config.demo_mode {
            info!("Running in demo mode");
            // In demo mode, we would simulate the application flow
            self.show_application_info(app_config);
            info!(name = %app_config.name, "Demo mode completed");
        } else {
            warn!("Interactive CLI mode not yet implemented in framework");
            info!("Application cells would be loaded and orchestrated here");
            self.show_application_info(app_config);
        }
        
        Ok(())
    }
    
    /// Run a service application
    async fn run_service_application(&self, app_config: &body_core::AppConfig) -> Result<(), Box<dyn std::error::Error>> {
        info!(name = %app_config.name, "Starting Service Application");
        
        // Create MockBus for now (would use NATS in production)
        let _bus = MockBus::new();
        
        info!("Using MockBus for cell communication");
        info!(cells = app_config.cells.len(), "Application would register cells");
        
        self.show_application_info(app_config);
        
        warn!("Service orchestration not yet implemented in framework");
        info!("Cells would be loaded, registered, and coordinated here");
        
        Ok(())
    }
    
    /// Show application information
    fn show_application_info(&self, app_config: &body_core::AppConfig) {
        info!("Application Details:");
        info!(name = %app_config.name, version = %app_config.version, desc = %app_config.description, "Meta");
        
        if !app_config.cells.is_empty() {
            info!("Cells:");
            for cell in &app_config.cells {
                info!(name = %cell.name, path = %cell.path, "cell");
            }
        }
        
        if !app_config.shared_cells.is_empty() {
            info!("Shared Cells:");
            for cell_name in &app_config.shared_cells {
                info!(name = %cell_name, "shared_cell");
            }
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize tracing subscriber once for the framework
    let _ = tracing_subscriber::registry()
        .with(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .with(fmt::layer().with_target(false).compact())
        .try_init();

    let config = BodyConfig::from_env_and_args();
    
    info!(
        nats_url = %config.nats_url,
        demo = config.demo_mode,
        mock_bus = config.use_mock_bus,
        app = config.app_name.as_deref().unwrap_or("<none>"),
        "CBS Framework Configuration"
    );
    
    let body = Body::new(config);
    body.run().await
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
    
    #[test]
    fn body_creation() {
        let config = BodyConfig::default();
        let body = Body::new(config.clone());
        assert_eq!(body.config.nats_url, config.nats_url);
    }
}