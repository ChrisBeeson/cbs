use async_trait::async_trait;
use body_core::{BodyBus, BusError, Cell, Envelope, MessageHandler};
use serde_json::{json, Value};
use std::io::{self, Write};

/// I/O cell that prints messages to stdout
pub struct PrinterCell {
    id: String,
}

impl PrinterCell {
    pub fn new() -> Self {
        Self {
            id: "io_print_greeting".to_string(),
        }
    }

    /// Print a message to stdout
    pub fn print_message(message: &str) -> Result<(), BusError> {
        println!("{}", message);
        io::stdout().flush()
            .map_err(|e| BusError::Internal(format!("Failed to flush stdout: {}", e)))
    }

    /// Print a message to a custom writer (for testing)
    pub fn print_message_to<W: Write>(writer: &mut W, message: &str) -> Result<(), BusError> {
        writeln!(writer, "{}", message)
            .map_err(|e| BusError::Internal(format!("Failed to write message: {}", e)))?;
        writer.flush()
            .map_err(|e| BusError::Internal(format!("Failed to flush writer: {}", e)))
    }

    /// Handle print request
    pub fn handle_print_request(envelope: Envelope) -> Result<Value, BusError> {
        // Extract message from payload
        let message = envelope
            .payload
            .as_ref()
            .and_then(|p| p.get("message"))
            .and_then(|m| m.as_str())
            .ok_or_else(|| BusError::BadRequest("Missing 'message' field in payload".to_string()))?;

        Self::print_message(message)?;

        Ok(json!({
            "printed": true,
            "message_length": message.len(),
            "timestamp": chrono::Utc::now().to_rfc3339()
        }))
    }
}

impl Default for PrinterCell {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl Cell for PrinterCell {
    fn id(&self) -> &str {
        &self.id
    }

    fn subjects(&self) -> Vec<String> {
        vec!["cbs.printer.write".to_string()]
    }

    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {
        let handler: MessageHandler = Box::new(|envelope| {
            PrinterCell::handle_print_request(envelope)
        });

        bus.subscribe("cbs.printer.write", handler).await
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn print_message_to_writer() {
        let mut buffer = Vec::new();
        let result = PrinterCell::print_message_to(&mut buffer, "Hello World!");
        
        assert!(result.is_ok());
        assert_eq!(String::from_utf8(buffer).unwrap(), "Hello World!\n");
    }

    #[test]
    fn print_empty_message() {
        let mut buffer = Vec::new();
        let result = PrinterCell::print_message_to(&mut buffer, "");
        
        assert!(result.is_ok());
        assert_eq!(String::from_utf8(buffer).unwrap(), "\n");
    }

    #[test]
    fn print_multiline_message() {
        let mut buffer = Vec::new();
        let message = "Line 1\nLine 2\nLine 3";
        let result = PrinterCell::print_message_to(&mut buffer, message);
        
        assert!(result.is_ok());
        assert_eq!(String::from_utf8(buffer).unwrap(), "Line 1\nLine 2\nLine 3\n");
    }

    #[test]
    fn print_message_with_special_characters() {
        let mut buffer = Vec::new();
        let message = "Hello 🌍! Café ñoño";
        let result = PrinterCell::print_message_to(&mut buffer, message);
        
        assert!(result.is_ok());
        assert_eq!(String::from_utf8(buffer).unwrap(), "Hello 🌍! Café ñoño\n");
    }

    #[test]
    fn handle_print_request_with_valid_payload() {
        let envelope = Envelope::new_request(
            "printer",
            "write",
            "demo/v1/Message",
            json!({"message": "Test message"})
        );

        let result = PrinterCell::handle_print_request(envelope).unwrap();
        assert_eq!(result["printed"], true);
        assert_eq!(result["message_length"], 12);
        assert!(result["timestamp"].is_string());
    }

    #[test]
    fn handle_print_request_with_missing_message() {
        let envelope = Envelope::new_request(
            "printer",
            "write",
            "demo/v1/Message",
            json!({})
        );

        let result = PrinterCell::handle_print_request(envelope);
        assert!(result.is_err());
        
        match result.unwrap_err() {
            BusError::BadRequest(msg) => assert!(msg.contains("Missing 'message' field")),
            _ => panic!("Expected BadRequest error"),
        }
    }

    #[test]
    fn handle_print_request_with_null_message() {
        let envelope = Envelope::new_request(
            "printer",
            "write",
            "demo/v1/Message",
            json!({"message": null})
        );

        let result = PrinterCell::handle_print_request(envelope);
        assert!(result.is_err());
        
        match result.unwrap_err() {
            BusError::BadRequest(msg) => assert!(msg.contains("Missing 'message' field")),
            _ => panic!("Expected BadRequest error"),
        }
    }

    #[test]
    fn handle_print_request_with_non_string_message() {
        let envelope = Envelope::new_request(
            "printer",
            "write",
            "demo/v1/Message",
            json!({"message": 123})
        );

        let result = PrinterCell::handle_print_request(envelope);
        assert!(result.is_err());
        
        match result.unwrap_err() {
            BusError::BadRequest(msg) => assert!(msg.contains("Missing 'message' field")),
            _ => panic!("Expected BadRequest error"),
        }
    }

    #[test]
    fn handle_print_request_with_empty_message() {
        let envelope = Envelope::new_request(
            "printer",
            "write",
            "demo/v1/Message",
            json!({"message": ""})
        );

        let result = PrinterCell::handle_print_request(envelope).unwrap();
        assert_eq!(result["printed"], true);
        assert_eq!(result["message_length"], 0);
    }

    #[test]
    fn cell_id_and_subjects() {
        let cell = PrinterCell::new();
        assert_eq!(cell.id(), "io_print_greeting");
        assert_eq!(cell.subjects(), vec!["cbs.printer.write"]);
    }

    #[test]
    fn cell_default_constructor() {
        let cell = PrinterCell::default();
        assert_eq!(cell.id(), "io_print_greeting");
    }
}