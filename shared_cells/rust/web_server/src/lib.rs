use axum::{
    extract::State,
    http::StatusCode,
    response::{Html, Json},
    routing::get,
    Router,
};
use body_core::{BodyBus, BusError, Cell};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tokio::net::TcpListener;
use tower_http::{
    cors::CorsLayer,
    services::{ServeDir, ServeFile},
};
use tracing::{info, warn};

/// Configuration for the web server
#[derive(Debug, Clone)]
pub struct WebServerConfig {
    pub static_dir: PathBuf,
    pub port: u16,
    pub enable_cors: bool,
}

impl Default for WebServerConfig {
    fn default() -> Self {
        Self {
            static_dir: PathBuf::from("./web"),
            port: 8080,
            enable_cors: true,
        }
    }
}

/// Web server cell that serves static files and provides health check
pub struct WebServerCell {
    config: WebServerConfig,
}

impl WebServerCell {
    pub fn new(config: WebServerConfig) -> Self {
        Self { config }
    }

    /// Start serving HTTP requests
    pub async fn serve(&self, listener: TcpListener) -> Result<(), Box<dyn std::error::Error>> {
        let app = self.create_app();
        
        info!(
            "Starting web server on {} serving files from {:?}",
            listener.local_addr()?,
            self.config.static_dir
        );
        
        axum::serve(listener, app).await?;
        Ok(())
    }

    /// Create the Axum application with routes and middleware
    fn create_app(&self) -> Router {
        let mut app = Router::new()
            .route("/health", get(health_check));

        // Serve static files
        let index_file = self.config.static_dir.join("index.html");
        if index_file.exists() {
            // Serve index.html for root path
            app = app.route("/", get(serve_index));
        }

        // Serve all other static files
        app = app.fallback_service(
            ServeDir::new(&self.config.static_dir)
                .not_found_service(ServeFile::new(self.config.static_dir.join("index.html")))
        );

        // Add state and CORS
        let app = app.with_state(self.config.clone());
        
        if self.config.enable_cors {
            app.layer(CorsLayer::permissive())
        } else {
            app
        }
    }
}

#[async_trait::async_trait]
impl Cell for WebServerCell {
    fn id(&self) -> &str {
        "web_server"
    }

    fn subjects(&self) -> Vec<String> {
        vec![
            "cbs.web_server.serve".to_string(),
            "cbs.web_server.health".to_string(),
        ]
    }

    async fn register(&self, _bus: &dyn BodyBus) -> Result<(), BusError> {
        info!("Registering web server cell with subjects: {:?}", self.subjects());
        
        // In a real implementation, we would register handlers for CBS messages
        // For now, we'll just log that registration is complete
        info!("Web server cell registered successfully");
        Ok(())
    }
}

/// Health check response
#[derive(Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    timestamp: String,
    server: String,
}

/// Health check endpoint
async fn health_check() -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "healthy".to_string(),
        timestamp: chrono::Utc::now().to_rfc3339(),
        server: "CBS Web Server".to_string(),
    })
}

/// Serve index.html for root path
async fn serve_index(State(config): State<WebServerConfig>) -> Result<Html<String>, StatusCode> {
    let index_path = config.static_dir.join("index.html");
    
    match tokio::fs::read_to_string(index_path).await {
        Ok(content) => Ok(Html(content)),
        Err(e) => {
            warn!("Failed to read index.html: {}", e);
            Err(StatusCode::NOT_FOUND)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_web_server_cell_creation() {
        let config = WebServerConfig::default();
        let cell = WebServerCell::new(config);
        
        assert_eq!(cell.id(), "web_server");
        assert!(cell.subjects().contains(&"cbs.web_server.serve".to_string()));
        assert!(cell.subjects().contains(&"cbs.web_server.health".to_string()));
    }

    #[test]
    fn test_config_default() {
        let config = WebServerConfig::default();
        
        assert_eq!(config.static_dir, PathBuf::from("./web"));
        assert_eq!(config.port, 8080);
        assert!(config.enable_cors);
    }

    #[tokio::test]
    async fn test_health_check_response() {
        let response = health_check().await;
        let health = response.0;
        
        assert_eq!(health.status, "healthy");
        assert_eq!(health.server, "CBS Web Server");
        assert!(!health.timestamp.is_empty());
    }
}
