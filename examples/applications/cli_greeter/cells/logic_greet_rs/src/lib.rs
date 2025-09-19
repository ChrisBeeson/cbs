use async_trait::async_trait;
use body_core::{BodyBus, BusError, Cell, Envelope, MessageHandler};
use serde_json::{json, Value};

/// Logic cell that formats greeting messages
pub struct GreeterCell {
    id: String,
}

impl GreeterCell {
    pub fn new() -> Self {
        Self {
            id: "logic_greet".to_string(),
        }
    }

    /// Format a greeting message from a name
    pub fn format_greeting(name: &str) -> String {
        if name.trim().is_empty() {
            "Hello there!".to_string()
        } else {
            format!("Hello {}!", name.trim())
        }
    }

    /// Handle greeting request
    pub fn handle_greeting_request(envelope: Envelope) -> Result<Value, BusError> {
        // Extract name from payload
        let name = envelope
            .payload
            .as_ref()
            .and_then(|p| p.get("name"))
            .and_then(|n| n.as_str())
            .unwrap_or("");

        let greeting = Self::format_greeting(name);
        
        Ok(json!({
            "message": greeting,
            "timestamp": chrono::Utc::now().to_rfc3339()
        }))
    }
}

impl Default for GreeterCell {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl Cell for GreeterCell {
    fn id(&self) -> &str {
        &self.id
    }

    fn subjects(&self) -> Vec<String> {
        vec!["cbs.greeter.say_hello".to_string()]
    }

    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {
        let handler: MessageHandler = Box::new(|envelope| {
            GreeterCell::handle_greeting_request(envelope)
        });

        bus.subscribe("cbs.greeter.say_hello", handler).await
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn formats_greeting_with_name() {
        let greeting = GreeterCell::format_greeting("Alice");
        assert_eq!(greeting, "Hello Alice!");
    }

    #[test]
    fn formats_greeting_with_whitespace_name() {
        let greeting = GreeterCell::format_greeting("  Bob  ");
        assert_eq!(greeting, "Hello Bob!");
    }

    #[test]
    fn formats_greeting_with_empty_name() {
        let greeting = GreeterCell::format_greeting("");
        assert_eq!(greeting, "Hello there!");
    }

    #[test]
    fn formats_greeting_with_whitespace_only() {
        let greeting = GreeterCell::format_greeting("   ");
        assert_eq!(greeting, "Hello there!");
    }

    #[test]
    fn handles_special_characters_in_name() {
        let greeting = GreeterCell::format_greeting("José María");
        assert_eq!(greeting, "Hello José María!");
    }

    #[test]
    fn handles_long_name() {
        let long_name = "Supercalifragilisticexpialidocious";
        let greeting = GreeterCell::format_greeting(long_name);
        assert_eq!(greeting, format!("Hello {}!", long_name));
    }

    #[test]
    fn handle_greeting_request_with_valid_payload() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello", 
            "demo/v1/Name",
            json!({"name": "Charlie"})
        );

        let result = GreeterCell::handle_greeting_request(envelope).unwrap();
        assert_eq!(result["message"], "Hello Charlie!");
        assert!(result["timestamp"].is_string());
    }

    #[test]
    fn handle_greeting_request_with_missing_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name", 
            json!({})
        );

        let result = GreeterCell::handle_greeting_request(envelope).unwrap();
        assert_eq!(result["message"], "Hello there!");
    }

    #[test]
    fn handle_greeting_request_with_null_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name",
            json!({"name": null})
        );

        let result = GreeterCell::handle_greeting_request(envelope).unwrap();
        assert_eq!(result["message"], "Hello there!");
    }

    #[test]
    fn handle_greeting_request_with_non_string_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name",
            json!({"name": 123})
        );

        let result = GreeterCell::handle_greeting_request(envelope).unwrap();
        assert_eq!(result["message"], "Hello there!");
    }

    #[test]
    fn cell_id_and_subjects() {
        let cell = GreeterCell::new();
        assert_eq!(cell.id(), "logic_greet");
        assert_eq!(cell.subjects(), vec!["cbs.greeter.say_hello"]);
    }

    #[test]
    fn cell_default_constructor() {
        let cell = GreeterCell::default();
        assert_eq!(cell.id(), "logic_greet");
    }
}