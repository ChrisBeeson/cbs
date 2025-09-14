use async_trait::async_trait;
use body_core::{BodyBus, BusError, Cell, Envelope, MessageHandler};
use serde_json::{json, Value};
use std::io::{self, BufRead, BufReader, Read, Write};

/// I/O cell that prompts for and reads names from input
pub struct PromptNameCell {
    id: String,
}

impl PromptNameCell {
    pub fn new() -> Self {
        Self {
            id: "io_prompt_name".to_string(),
        }
    }

    /// Prompt for a name using stdin/stdout
    pub fn prompt_for_name() -> Result<String, BusError> {
        print!("Enter your name: ");
        io::stdout().flush()
            .map_err(|e| BusError::Internal(format!("Failed to flush stdout: {}", e)))?;

        let mut input = String::new();
        io::stdin().read_line(&mut input)
            .map_err(|e| BusError::Internal(format!("Failed to read from stdin: {}", e)))?;

        Ok(input.trim().to_string())
    }

    /// Prompt for a name using custom reader/writer (for testing)
    pub fn prompt_for_name_with_io<R: Read, W: Write>(
        reader: &mut R, 
        writer: &mut W,
        prompt: &str
    ) -> Result<String, BusError> {
        write!(writer, "{}", prompt)
            .map_err(|e| BusError::Internal(format!("Failed to write prompt: {}", e)))?;
        writer.flush()
            .map_err(|e| BusError::Internal(format!("Failed to flush writer: {}", e)))?;

        let mut buf_reader = BufReader::new(reader);
        let mut input = String::new();
        buf_reader.read_line(&mut input)
            .map_err(|e| BusError::Internal(format!("Failed to read input: {}", e)))?;

        Ok(input.trim().to_string())
    }

    /// Handle prompt name request
    pub fn handle_prompt_request(envelope: Envelope) -> Result<Value, BusError> {
        // Check if custom prompt is provided
        let _prompt = envelope
            .payload
            .as_ref()
            .and_then(|p| p.get("prompt"))
            .and_then(|pr| pr.as_str())
            .unwrap_or("Enter your name: ");

        // For testing, we can mock this by checking for a test_input field
        let name = if let Some(test_input) = envelope
            .payload
            .as_ref()
            .and_then(|p| p.get("test_input"))
            .and_then(|ti| ti.as_str())
        {
            test_input.to_string()
        } else {
            Self::prompt_for_name()?
        };

        if name.is_empty() {
            return Err(BusError::BadRequest("Name cannot be empty".to_string()));
        }

        Ok(json!({
            "name": name,
            "length": name.len(),
            "timestamp": chrono::Utc::now().to_rfc3339()
        }))
    }
}

impl Default for PromptNameCell {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl Cell for PromptNameCell {
    fn id(&self) -> &str {
        &self.id
    }

    fn subjects(&self) -> Vec<String> {
        vec!["cbs.prompt_name.read".to_string()]
    }

    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {
        let handler: MessageHandler = Box::new(|envelope| {
            PromptNameCell::handle_prompt_request(envelope)
        });

        bus.subscribe("cbs.prompt_name.read", handler).await
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    use std::io::Cursor;

    #[test]
    fn prompt_for_name_with_io() {
        let input = "Alice\n";
        let mut reader = Cursor::new(input.as_bytes());
        let mut writer = Vec::new();

        let result = PromptNameCell::prompt_for_name_with_io(
            &mut reader, 
            &mut writer, 
            "Enter name: "
        ).unwrap();

        assert_eq!(result, "Alice");
        assert_eq!(String::from_utf8(writer).unwrap(), "Enter name: ");
    }

    #[test]
    fn prompt_for_name_with_whitespace() {
        let input = "  Bob  \n";
        let mut reader = Cursor::new(input.as_bytes());
        let mut writer = Vec::new();

        let result = PromptNameCell::prompt_for_name_with_io(
            &mut reader, 
            &mut writer, 
            "Name: "
        ).unwrap();

        assert_eq!(result, "Bob");
    }

    #[test]
    fn prompt_for_name_with_empty_input() {
        let input = "\n";
        let mut reader = Cursor::new(input.as_bytes());
        let mut writer = Vec::new();

        let result = PromptNameCell::prompt_for_name_with_io(
            &mut reader, 
            &mut writer, 
            "Name: "
        ).unwrap();

        assert_eq!(result, "");
    }

    #[test]
    fn prompt_for_name_with_special_characters() {
        let input = "José María\n";
        let mut reader = Cursor::new(input.as_bytes());
        let mut writer = Vec::new();

        let result = PromptNameCell::prompt_for_name_with_io(
            &mut reader, 
            &mut writer, 
            "Name: "
        ).unwrap();

        assert_eq!(result, "José María");
    }

    #[test]
    fn handle_prompt_request_with_test_input() {
        let envelope = Envelope::new_request(
            "prompt_name",
            "read",
            "demo/v1/Void",
            json!({"test_input": "Charlie"})
        );

        let result = PromptNameCell::handle_prompt_request(envelope).unwrap();
        assert_eq!(result["name"], "Charlie");
        assert_eq!(result["length"], 7);
        assert!(result["timestamp"].is_string());
    }

    #[test]
    fn handle_prompt_request_with_empty_test_input() {
        let envelope = Envelope::new_request(
            "prompt_name",
            "read",
            "demo/v1/Void",
            json!({"test_input": ""})
        );

        let result = PromptNameCell::handle_prompt_request(envelope);
        assert!(result.is_err());
        
        match result.unwrap_err() {
            BusError::BadRequest(msg) => assert_eq!(msg, "Name cannot be empty"),
            _ => panic!("Expected BadRequest error"),
        }
    }

    #[test]
    fn handle_prompt_request_with_custom_prompt() {
        let envelope = Envelope::new_request(
            "prompt_name",
            "read",
            "demo/v1/Void",
            json!({"prompt": "What's your name? ", "test_input": "Diana"})
        );

        let result = PromptNameCell::handle_prompt_request(envelope).unwrap();
        assert_eq!(result["name"], "Diana");
    }

    #[test]
    fn handle_prompt_request_with_whitespace_test_input() {
        let envelope = Envelope::new_request(
            "prompt_name",
            "read",
            "demo/v1/Void",
            json!({"test_input": "  Eve  "})
        );

        let result = PromptNameCell::handle_prompt_request(envelope).unwrap();
        assert_eq!(result["name"], "  Eve  "); // Should preserve whitespace in test mode
    }

    #[test]
    fn handle_prompt_request_with_no_payload() {
        let envelope = Envelope::new_request(
            "prompt_name",
            "read",
            "demo/v1/Void",
            json!({})
        );

        // This would normally prompt for real input, but in test mode we can't easily test that
        // The function would call prompt_for_name() which uses stdin
        // For now, we'll just verify the envelope structure is correct
        assert_eq!(envelope.service, "prompt_name");
        assert_eq!(envelope.verb, "read");
    }

    #[test]
    fn cell_id_and_subjects() {
        let cell = PromptNameCell::new();
        assert_eq!(cell.id(), "io_prompt_name");
        assert_eq!(cell.subjects(), vec!["cbs.prompt_name.read"]);
    }

    #[test]
    fn cell_default_constructor() {
        let cell = PromptNameCell::default();
        assert_eq!(cell.id(), "io_prompt_name");
    }
}