use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use thiserror::Error;
use uuid::Uuid;

/// Envelope represents a typed message in the CBS system
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Envelope {
    pub id: String,
    pub service: String,
    pub verb: String,
    pub schema: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub payload: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<ErrorDetails>,
}

/// Error details for envelope error responses
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ErrorDetails {
    pub code: String,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub details: Option<Value>,
}

/// Bus-level errors
#[derive(Debug, Error)]
pub enum BusError {
    #[error("Request timeout: no response received within deadline")]
    Timeout,
    #[error("Bad request: {0}")]
    BadRequest(String),
    #[error("Not found: {0}")]
    NotFound(String),
    #[error("Internal error: {0}")]
    Internal(String),
    #[error("Connection error: {0}")]
    Connection(String),
    #[error("Serialization error: {0}")]
    Serialization(String),
}

/// Handler function type for message processing
pub type MessageHandler = Box<dyn Fn(Envelope) -> Result<Value, BusError> + Send + Sync>;

/// Message bus interface for request/reply and subscription patterns
#[async_trait]
pub trait BodyBus: Send + Sync {
    /// Send a request and wait for a reply
    async fn request(&self, envelope: Envelope) -> Result<Value, BusError>;

    /// Subscribe to a subject with a handler function
    async fn subscribe(&self, subject: &str, handler: MessageHandler) -> Result<(), BusError>;
}

/// Cell interface for registering handlers with the bus
#[async_trait]
pub trait Cell: Send + Sync {
    /// Unique identifier for this cell
    fn id(&self) -> &str;

    /// List of subjects this cell subscribes to
    fn subjects(&self) -> Vec<String>;

    /// Register this cell's handlers with the bus
    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError>;
}

impl Envelope {
    /// Create a new request envelope
    pub fn new_request(service: &str, verb: &str, schema: &str, payload: Value) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            service: service.to_string(),
            verb: verb.to_string(),
            schema: schema.to_string(),
            payload: Some(payload),
            error: None,
        }
    }

    /// Create a new success response envelope
    pub fn new_response(
        request_id: &str,
        service: &str,
        verb: &str,
        schema: &str,
        payload: Value,
    ) -> Self {
        Self {
            id: request_id.to_string(),
            service: service.to_string(),
            verb: verb.to_string(),
            schema: schema.to_string(),
            payload: Some(payload),
            error: None,
        }
    }

    /// Create a new error response envelope
    pub fn new_error(
        request_id: &str,
        service: &str,
        verb: &str,
        schema: &str,
        error: ErrorDetails,
    ) -> Self {
        Self {
            id: request_id.to_string(),
            service: service.to_string(),
            verb: verb.to_string(),
            schema: schema.to_string(),
            payload: None,
            error: Some(error),
        }
    }

    /// Check if this envelope represents an error
    pub fn is_error(&self) -> bool {
        self.error.is_some()
    }

    /// Get the NATS subject for this envelope
    pub fn subject(&self) -> String {
        format!("cbs.{}.{}", self.service, self.verb)
    }
}

impl ErrorDetails {
    /// Create new error details
    pub fn new(code: &str, message: &str) -> Self {
        Self {
            code: code.to_string(),
            message: message.to_string(),
            details: None,
        }
    }

    /// Create new error details with additional context
    pub fn with_details(code: &str, message: &str, details: Value) -> Self {
        Self {
            code: code.to_string(),
            message: message.to_string(),
            details: Some(details),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn envelope_roundtrip_serialization() {
        let envelope = Envelope {
            id: "test-id".to_string(),
            service: "greeter".to_string(),
            verb: "say_hello".to_string(),
            schema: "demo/v1/Name".to_string(),
            payload: Some(json!({"name": "Ada"})),
            error: None,
        };

        let serialized = serde_json::to_string(&envelope).unwrap();
        let deserialized: Envelope = serde_json::from_str(&serialized).unwrap();

        assert_eq!(envelope, deserialized);
        assert_eq!(deserialized.service, "greeter");
        assert_eq!(deserialized.verb, "say_hello");
        assert_eq!(deserialized.payload.unwrap()["name"], "Ada");
    }

    #[test]
    fn envelope_error_serialization() {
        let error_details = ErrorDetails::new("BadRequest", "Invalid input");
        let envelope = Envelope::new_error(
            "test-id",
            "greeter",
            "say_hello",
            "demo/v1/Error",
            error_details,
        );

        let serialized = serde_json::to_string(&envelope).unwrap();
        let deserialized: Envelope = serde_json::from_str(&serialized).unwrap();

        assert!(deserialized.is_error());
        assert_eq!(deserialized.error.unwrap().code, "BadRequest");
        assert!(deserialized.payload.is_none());
    }

    #[test]
    fn envelope_validates_snake_case_service_verb() {
        let envelope =
            Envelope::new_request("prompt_name", "read_input", "demo/v1/Void", json!({}));
        assert_eq!(envelope.service, "prompt_name");
        assert_eq!(envelope.verb, "read_input");
        assert_eq!(envelope.subject(), "cbs.prompt_name.read_input");
    }

    #[test]
    fn envelope_generates_uuid_v4() {
        let envelope = Envelope::new_request("test", "action", "demo/v1/Test", json!({}));

        // UUID v4 should be 36 characters with hyphens
        assert_eq!(envelope.id.len(), 36);
        assert!(envelope.id.contains('-'));

        // Should be parseable as UUID
        Uuid::parse_str(&envelope.id).unwrap();
    }

    #[test]
    fn envelope_schema_format_validation() {
        let envelope = Envelope::new_request("test", "action", "demo/v1/TestType", json!({}));
        assert_eq!(envelope.schema, "demo/v1/TestType");

        // Test different valid schema formats
        let envelope2 =
            Envelope::new_request("test", "action", "user_service/v2/UserProfile", json!({}));
        assert_eq!(envelope2.schema, "user_service/v2/UserProfile");
    }

    #[test]
    fn envelope_mutual_exclusion_payload_error() {
        // Success envelope should have payload, no error
        let success = Envelope::new_response(
            "id",
            "test",
            "action",
            "demo/v1/Result",
            json!({"ok": true}),
        );
        assert!(success.payload.is_some());
        assert!(success.error.is_none());
        assert!(!success.is_error());

        // Error envelope should have error, no payload
        let error = Envelope::new_error(
            "id",
            "test",
            "action",
            "demo/v1/Error",
            ErrorDetails::new("Internal", "Something went wrong"),
        );
        assert!(error.payload.is_none());
        assert!(error.error.is_some());
        assert!(error.is_error());
    }

    #[test]
    fn error_details_with_context() {
        let details = ErrorDetails::with_details(
            "ValidationError",
            "Field validation failed",
            json!({"field": "name", "constraint": "required"}),
        );

        assert_eq!(details.code, "ValidationError");
        assert_eq!(details.message, "Field validation failed");
        assert_eq!(details.details.unwrap()["field"], "name");
    }

    #[test]
    fn bus_error_display_messages() {
        assert_eq!(
            BusError::Timeout.to_string(),
            "Request timeout: no response received within deadline"
        );
        assert_eq!(
            BusError::BadRequest("missing field".to_string()).to_string(),
            "Bad request: missing field"
        );
        assert_eq!(
            BusError::NotFound("service".to_string()).to_string(),
            "Not found: service"
        );
        assert_eq!(
            BusError::Internal("database error".to_string()).to_string(),
            "Internal error: database error"
        );
        assert_eq!(
            BusError::Connection("NATS unavailable".to_string()).to_string(),
            "Connection error: NATS unavailable"
        );
        assert_eq!(
            BusError::Serialization("invalid JSON".to_string()).to_string(),
            "Serialization error: invalid JSON"
        );
    }

    #[test]
    fn bus_error_propagation() {
        fn simulate_error() -> Result<(), BusError> {
            Err(BusError::Timeout)
        }

        let result = simulate_error();
        assert!(result.is_err());

        match result.unwrap_err() {
            BusError::Timeout => {} // Expected
            _ => panic!("Expected Timeout error"),
        }
    }
}
