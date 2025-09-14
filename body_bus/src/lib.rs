use async_nats::{Client, ConnectOptions};
use body_core::{BodyBus, BusError, Envelope, MessageHandler};
use futures_util::StreamExt;
use serde_json::Value;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::RwLock;
use tokio::time::timeout;

/// NATS-based implementation of the BodyBus trait
pub struct NatsBus {
    client: Client,
    config: NatsBusConfig,
    handlers: Arc<RwLock<std::collections::HashMap<String, MessageHandler>>>,
}

impl std::fmt::Debug for NatsBus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("NatsBus")
            .field("config", &self.config)
            .field("handlers", &format!("{} handlers", self.handlers.try_read().map_or(0, |h| h.len())))
            .finish()
    }
}

/// Configuration for NATS bus connection and behavior
#[derive(Debug, Clone)]
pub struct NatsBusConfig {
    pub url: String,
    pub request_timeout: Duration,
    pub connection_timeout: Duration,
    pub max_reconnect_attempts: usize,
    pub reconnect_delay: Duration,
}

impl Default for NatsBusConfig {
    fn default() -> Self {
        Self {
            url: "nats://localhost:4222".to_string(),
            request_timeout: Duration::from_secs(5),
            connection_timeout: Duration::from_secs(10),
            max_reconnect_attempts: 10,
            reconnect_delay: Duration::from_millis(500),
        }
    }
}

impl NatsBus {
    /// Create a new NATS bus with default configuration
    pub async fn connect(url: &str) -> Result<Self, BusError> {
        let config = NatsBusConfig {
            url: url.to_string(),
            ..Default::default()
        };
        Self::connect_with_config(config).await
    }

    /// Create a new NATS bus with custom configuration
    pub async fn connect_with_config(config: NatsBusConfig) -> Result<Self, BusError> {
        let connect_options = ConnectOptions::new()
            .connection_timeout(config.connection_timeout);

        let client = timeout(
            config.connection_timeout,
            async_nats::connect_with_options(&config.url, connect_options),
        )
        .await
        .map_err(|_| BusError::Connection("Connection timeout".to_string()))?
        .map_err(|e| BusError::Connection(format!("NATS connection failed: {}", e)))?;

        Ok(Self {
            client,
            config,
            handlers: Arc::new(RwLock::new(std::collections::HashMap::new())),
        })
    }

    /// Get connection status
    pub fn is_connected(&self) -> bool {
        self.client.connection_state() == async_nats::connection::State::Connected
    }

    /// Get server information
    pub fn server_info(&self) -> async_nats::ServerInfo {
        self.client.server_info()
    }
}

#[async_trait::async_trait]
impl BodyBus for NatsBus {
    async fn request(&self, envelope: Envelope) -> Result<Value, BusError> {
        let subject = envelope.subject();
        let payload = serde_json::to_vec(&envelope)
            .map_err(|e| BusError::Serialization(format!("Failed to serialize envelope: {}", e)))?;

        let response = timeout(
            self.config.request_timeout,
            self.client.request(subject, payload.into()),
        )
        .await
        .map_err(|_| BusError::Timeout)?
        .map_err(|e| {
            let error_str = e.to_string();
            if error_str.contains("no responders") {
                BusError::NotFound("No subscribers for subject".to_string())
            } else {
                BusError::Connection(format!("NATS request failed: {}", e))
            }
        })?;

        let response_envelope: Envelope = serde_json::from_slice(&response.payload)
            .map_err(|e| BusError::Serialization(format!("Failed to deserialize response: {}", e)))?;

        if response_envelope.is_error() {
            let error = response_envelope.error.unwrap();
            match error.code.as_str() {
                "BadRequest" => Err(BusError::BadRequest(error.message)),
                "NotFound" => Err(BusError::NotFound(error.message)),
                "Timeout" => Err(BusError::Timeout),
                _ => Err(BusError::Internal(error.message)),
            }
        } else {
            response_envelope.payload.ok_or_else(|| {
                BusError::Internal("Response envelope missing payload".to_string())
            })
        }
    }

    async fn subscribe(&self, subject: &str, handler: MessageHandler) -> Result<(), BusError> {
        let subject_owned = subject.to_string();
        
        // Store handler for potential cleanup
        {
            let mut handlers = self.handlers.write().await;
            handlers.insert(subject_owned.clone(), handler);
        }

        let handlers_ref = Arc::clone(&self.handlers);
        let subject_for_handler = subject_owned.clone();
        let client_ref = self.client.clone();

        let mut subscriber = self
            .client
            .queue_subscribe(subject_owned.clone(), extract_queue_group(&subject_owned))
            .await
            .map_err(|e| BusError::Connection(format!("Failed to subscribe: {}", e)))?;

        tokio::spawn(async move {
            while let Some(message) = subscriber.next().await {
                let envelope: Envelope = match serde_json::from_slice(&message.payload) {
                    Ok(env) => env,
                    Err(e) => {
                        eprintln!("Failed to deserialize message: {}", e);
                        continue;
                    }
                };

                let response = {
                    let handlers = handlers_ref.read().await;
                    if let Some(handler) = handlers.get(&subject_for_handler) {
                        handler(envelope.clone())
                    } else {
                        Err(BusError::NotFound("Handler not found".to_string()))
                    }
                };

                let response_envelope = match response {
                    Ok(payload) => Envelope::new_response(
                        &envelope.id,
                        &envelope.service,
                        &envelope.verb,
                        &envelope.schema,
                        payload,
                    ),
                    Err(e) => {
                        let error_details = body_core::ErrorDetails::new(
                            &match e {
                                BusError::BadRequest(_) => "BadRequest",
                                BusError::NotFound(_) => "NotFound", 
                                BusError::Timeout => "Timeout",
                                _ => "Internal",
                            },
                            &e.to_string(),
                        );
                        Envelope::new_error(
                            &envelope.id,
                            &envelope.service,
                            &envelope.verb,
                            &envelope.schema,
                            error_details,
                        )
                    }
                };

                if let Ok(response_payload) = serde_json::to_vec(&response_envelope) {
                    if let Some(reply) = message.reply {
                        if let Err(e) = client_ref.publish(reply, response_payload.into()).await {
                            eprintln!("Failed to send response: {}", e);
                        }
                    }
                }
            }
        });

        Ok(())
    }
}

/// Extract queue group name from subject (service part)
fn extract_queue_group(subject: &str) -> String {
    // For subject "cbs.service.verb", extract "service" as queue group
    if let Some(parts) = subject.strip_prefix("cbs.") {
        if let Some(service) = parts.split('.').next() {
            return service.to_string();
        }
    }
    "default".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use body_core::Envelope;
    use serde_json::json;

    #[tokio::test]
    async fn envelope_serialization_roundtrip() {
        let envelope = Envelope::new_request("test", "action", "demo/v1/Test", json!({"key": "value"}));
        
        let serialized = serde_json::to_vec(&envelope).unwrap();
        let deserialized: Envelope = serde_json::from_slice(&serialized).unwrap();
        
        assert_eq!(envelope.id, deserialized.id);
        assert_eq!(envelope.service, deserialized.service);
        assert_eq!(envelope.verb, deserialized.verb);
        assert_eq!(envelope.payload, deserialized.payload);
    }

    #[test]
    fn extract_queue_group_from_subject() {
        assert_eq!(extract_queue_group("cbs.greeter.say_hello"), "greeter");
        assert_eq!(extract_queue_group("cbs.prompt_name.read"), "prompt_name");
        assert_eq!(extract_queue_group("cbs.printer.write"), "printer");
        assert_eq!(extract_queue_group("invalid.subject"), "default");
        assert_eq!(extract_queue_group("cbs.service"), "service");
    }

    #[test]
    fn nats_bus_config_defaults() {
        let config = NatsBusConfig::default();
        assert_eq!(config.url, "nats://localhost:4222");
        assert_eq!(config.request_timeout, Duration::from_secs(5));
        assert_eq!(config.connection_timeout, Duration::from_secs(10));
        assert_eq!(config.max_reconnect_attempts, 10);
    }
}