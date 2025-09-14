use async_trait::async_trait;
use body_core::{BodyBus, BusError, Cell, Envelope, MessageHandler};
use serde_json::{json, Value};

/// Simple greeter cell that combines name prompting and greeting logic
pub struct GreeterCell {
    id: String,
}

impl GreeterCell {
    pub fn new() -> Self {
        Self {
            id: "greeter".to_string(),
        }
    }

    /// Handle say hello request
    pub fn handle_say_hello(envelope: Envelope) -> Result<Value, BusError> {
        // Extract name from payload
        let name = envelope
            .payload
            .as_ref()
            .and_then(|p| p.get("name"))
            .and_then(|n| n.as_str())
            .unwrap_or("World");

        let message = if name.trim().is_empty() {
            "Hello World!".to_string()
        } else {
            format!("Hello {}!", name.trim())
        };

        Ok(json!({
            "message": message
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
            GreeterCell::handle_say_hello(envelope)
        });

        bus.subscribe("cbs.greeter.say_hello", handler).await
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn handle_say_hello_with_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name",
            json!({"name": "Alice"})
        );

        let result = GreeterCell::handle_say_hello(envelope).unwrap();
        assert_eq!(result["message"], "Hello Alice!");
    }

    #[test]
    fn handle_say_hello_with_empty_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name",
            json!({"name": ""})
        );

        let result = GreeterCell::handle_say_hello(envelope).unwrap();
        assert_eq!(result["message"], "Hello World!");
    }

    #[test]
    fn handle_say_hello_with_no_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name",
            json!({})
        );

        let result = GreeterCell::handle_say_hello(envelope).unwrap();
        assert_eq!(result["message"], "Hello World!");
    }

    #[test]
    fn handle_say_hello_with_whitespace_name() {
        let envelope = Envelope::new_request(
            "greeter",
            "say_hello",
            "demo/v1/Name",
            json!({"name": "  Bob  "})
        );

        let result = GreeterCell::handle_say_hello(envelope).unwrap();
        assert_eq!(result["message"], "Hello Bob!");
    }

    #[test]
    fn cell_id_and_subjects() {
        let cell = GreeterCell::new();
        assert_eq!(cell.id(), "greeter");
        assert_eq!(cell.subjects(), vec!["cbs.greeter.say_hello"]);
    }

    #[test]
    fn cell_default_constructor() {
        let cell = GreeterCell::default();
        assert_eq!(cell.id(), "greeter");
    }
}