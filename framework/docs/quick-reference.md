# CBS Quick Reference

## The Golden Rules

1. **CELLS MUST ONLY COMMUNICATE THROUGH THE BUS** - Never direct calls
2. **Design message contracts first** - Implementation follows contracts
3. **Think in messages, not method calls** - Async message passing only
4. **Embrace isolation** - Cells cannot directly affect each other
5. **Trust the bus** - Let NATS handle delivery, routing, and scaling

## Message Pattern

### Subject Format
```
cbs.{service}.{verb}
```
- `cbs.user_service.get_user`
- `cbs.payment_processor.charge_card`
- `cbs.ui_component.render_view`

### Envelope Structure
```json
{
  "id": "uuid-v4",
  "service": "user_service",
  "verb": "get_user", 
  "schema": "user/v1/GetUser",
  "payload": {"id": "123"},
  "error": null
}
```

## Cell Implementation Template

### Rust Cell
```rust
use async_trait::async_trait;
use body_core::{BodyBus, BusError, Cell, Envelope};
use serde_json::{json, Value};

pub struct MyCell {
    id: String,
}

impl MyCell {
    pub fn new() -> Self {
        Self { id: "my_service".to_string() }
    }
    
    fn handle_my_action(envelope: Envelope) -> Result<Value, BusError> {
        // Extract payload
        let data = envelope.payload
            .as_ref()
            .and_then(|p| p.get("field"))
            .and_then(|f| f.as_str())
            .ok_or_else(|| BusError::BadRequest("Missing field".to_string()))?;
            
        // Process and respond
        Ok(json!({"result": format!("Processed: {}", data)}))
    }
}

#[async_trait]
impl Cell for MyCell {
    fn id(&self) -> &str { &self.id }
    
    fn subjects(&self) -> Vec<String> {
        vec!["cbs.my_service.my_action".to_string()]
    }
    
    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {
        bus.subscribe("cbs.my_service.my_action", 
            Box::new(|envelope| Self::handle_my_action(envelope))
        ).await
    }
}
```

### Dart Cell
```dart
import 'package:cbs_sdk/cbs_sdk.dart';

class MyCell implements Cell {
  @override
  String get id => 'my_service';
  
  @override
  List<String> get subjects => ['cbs.my_service.my_action'];
  
  @override
  Future<void> register(BodyBus bus) async {
    await bus.subscribe('cbs.my_service.my_action', _handleMyAction);
  }
  
  Future<Map<String, dynamic>> _handleMyAction(Envelope envelope) async {
    final data = envelope.payload?['field'] as String?;
    if (data == null) {
      throw BusError.badRequest('Missing field');
    }
    
    return {
      'result': 'Processed: $data',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
```

## Common Patterns

### Request/Response
```rust
// Send request
let envelope = Envelope::new_request(
    "user_service", "get_user",
    "user/v1/GetUser", 
    json!({"id": "123"})
);
let response = bus.request(envelope).await?;

// Handle response
let user_name = response["name"].as_str().unwrap();
```

### Error Handling
```rust
// Return error from cell
Err(BusError::BadRequest("Invalid user ID".to_string()))

// Handle error in caller
match bus.request(envelope).await {
    Ok(data) => tracing::info!(?data, "Success"),
    Err(BusError::NotFound(msg)) => tracing::warn!(%msg, "Not found"),
    Err(e) => tracing::error!(error = %e, "Error"),
}
```

### Testing
```rust
#[test]
fn test_cell_handler() {
    let envelope = Envelope::new_request(
        "my_service", "my_action",
        "test/v1/MyAction",
        json!({"field": "test_value"})
    );
    
    let result = MyCell::handle_my_action(envelope).unwrap();
    assert_eq!(result["result"], "Processed: test_value");
}

#[tokio::test]
async fn test_with_mock_bus() {
    let bus = MockBus::new();
    let cell = MyCell::new();
    cell.register(&bus).await.unwrap();
    
    let envelope = Envelope::new_request(
        "my_service", "my_action",
        "test/v1/MyAction", 
        json!({"field": "test"})
    );
    
    let response = bus.request(envelope).await.unwrap();
    assert_eq!(response["result"], "Processed: test");
}
```

## Application Structure

### app.yaml
```yaml
name: my_app
version: 1.0.0
description: My CBS application
cells:
  - name: user_service
    path: cells/user_service
  - name: web_ui
    path: cells/web_ui
shared_cells:
  - cbs_sdk
```

### Directory Structure
```
my_app/
├── app.yaml
└── cells/
    ├── user_service/
    │   ├── .cbs-spec/spec.md
    │   ├── src/lib.rs
    │   ├── Cargo.toml
    │   └── tests/
    └── web_ui/
        ├── .cbs-spec/spec.md
        ├── lib/main.dart
        ├── pubspec.yaml
        └── test/
```

## Schema Versioning

### Format
```
domain/v{major}/TypeName
```

### Examples
- `user/v1/Profile` - User profile data
- `payment/v2/Transaction` - Payment transaction (v2 has breaking changes)
- `ui/v1/RenderRequest` - UI rendering request

### Evolution
- **Patch changes**: No version bump (add optional fields)
- **Minor changes**: No version bump (backward compatible)
- **Major changes**: Bump version (breaking changes)

## Running Applications

### Development
```bash
# With mock bus
body --app my_app --mock-bus

# With NATS
body --app my_app --nats-url nats://localhost:4222
```

### Production
```bash
# Start NATS cluster
nats-server --cluster nats://0.0.0.0:4248 --routes nats://node1:4248,nats://node2:4248

# Run application
body --app my_app --nats-url nats://cluster:4222
```

## Debugging

### Correlation IDs
Every message has a UUID for tracing:
```rust
use tracing::info;
info!(request_id = %envelope.id, "Processing request");
```

### Message Monitoring
Use the bus monitor cell to see all messages in real-time:
```yaml
cells:
  - name: bus_monitor
    path: shared_cells/bus_monitor
```

### Logging
```rust
use tracing::{info, error, debug};

info!(cell = %self.id(), subject = %envelope.subject(), "Handling request");
error!(request_id = %envelope.id, error = %error, "Failed to process request");
```

## Common Anti-Patterns

### ❌ Don't Do This
```rust
// Direct cell communication
let other_cell = UserServiceCell::new();
let user = other_cell.get_user("123");

// Shared state
static GLOBAL_DATA: Mutex<HashMap<String, String>> = ...;

// Importing other cells
use other_cell::SomeFunction;
```

### ✅ Do This Instead
```rust
// Message-based communication
let envelope = Envelope::new_request(
    "user_service", "get_user",
    "user/v1/GetUser",
    json!({"id": "123"})
);
let user = bus.request(envelope).await?;

// State through messages
let envelope = Envelope::new_request(
    "storage_service", "get_data",
    "storage/v1/GetData",
    json!({"key": "user_123"})
);
let data = bus.request(envelope).await?;
```

## Performance Tips

### Message Batching
```rust
// For high-throughput scenarios
let batch_envelope = Envelope::new_request(
    "processor", "batch_process",
    "processor/v1/BatchProcess",
    json!({"items": vec![item1, item2, item3]})
);
```

### Connection Pooling
NATS handles connection pooling automatically - trust the bus!

### Async Patterns
```rust
// Process multiple requests concurrently
let futures: Vec<_> = requests.into_iter()
    .map(|req| bus.request(req))
    .collect();
    
let responses = futures::future::join_all(futures).await;
```

## Need Help?

1. **Read [The CBS Way](the-cbs-way.md)** for the fundamental concepts
2. **Check [Architecture Guide](architecture.md)** for detailed design
3. **Explore examples** in `examples/` directory
4. **Follow the [Getting Started](getting-started.md)** tutorial
5. **Ask questions** in the community discussions

**Remember: CBS is about biological isolation and message-only communication. Embrace the paradigm shift!** 🧬
