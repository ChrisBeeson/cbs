# CBS Framework Architecture

## The Revolutionary Approach

Cell Body System (CBS) represents a **paradigm shift** in software architecture. Unlike traditional systems where components call each other directly, CBS is inspired by biological systems where cells operate in complete isolation and communicate only through a shared medium (like the bloodstream).

**This is not just another microservices framework** - it's a fundamentally different way of thinking about software design that eliminates direct dependencies entirely.

## Core Principles

### 1. Biological Isolation - The Foundation

**THE CARDINAL RULE: Cells MUST ONLY communicate through the bus - NEVER direct cell-to-cell calls**

This is not a suggestion or best practice - it's an **architectural law** that enables everything else:

```
❌ TRADITIONAL: Component A → Component B.method()
✅ CBS: Cell A → Bus → Cell B (via message)
```

**Why This Matters:**
- **Zero coupling**: No cell knows about any other cell's existence
- **Language freedom**: Rust cells talk to Dart cells seamlessly
- **Distributed ready**: Cells can run anywhere, NATS handles delivery
- **Fault isolation**: One cell crash doesn't affect others
- **Hot swapping**: Replace cells without system restart
- **Observable**: Every interaction is visible on the bus

### 2. Contract-First Development
- Every cell has `ai/spec.md` defining its message interface before implementation
- **Typed envelopes** with versioned schemas ensure compatibility
- Messages are the **only** API - no methods, no imports, no direct calls
- Contracts are language-agnostic and enforceable

### 3. Cellular Responsibility
- Each cell performs **one clear capability** (like a biological cell)
- Cells can be large internally but must have **clean message boundaries**
- No shared state between cells - all data flows through messages
- Cells are **self-contained units** that can be developed, tested, and deployed independently

### 4. Message-Only Communication
- **All** communication happens through typed `Envelope` messages
- Subject format: `cbs.{service}.{verb}` (e.g., `cbs.greeter.say_hello`)
- Every message has a correlation ID for tracing
- Schema versioning enables evolution without breaking changes
- Request/reply pattern with automatic routing via NATS

## The Paradigm Shift: Traditional vs CBS

### Traditional Architecture Problems

```
❌ Traditional Monolith:
UI Component → Service.method() → Database.query()

❌ Traditional Microservices:
Service A → HTTP REST API → Service B → Database
```

**Problems:**
- **Tight coupling**: Components know about each other
- **Language lock-in**: All components must use compatible languages/frameworks
- **Fragile**: One component change can break others
- **Hard to test**: Need to mock complex dependency chains
- **Deployment complexity**: Must coordinate releases
- **Scaling issues**: Hotspots create bottlenecks

### CBS Solution

```
✅ CBS Architecture:
UI Cell → Bus Message → Logic Cell → Bus Message → Storage Cell
```

**Benefits:**
- **Zero coupling**: Cells don't know about each other
- **Polyglot**: Mix Rust, Dart, Python, etc. naturally
- **Resilient**: Cell failures don't cascade
- **Testable**: Mock the bus, not complex objects
- **Independent deployment**: Replace cells without affecting others
- **Natural scaling**: NATS handles load balancing

### Mindset Shift Required

**Old Thinking:**
```rust
// Traditional approach
let user = user_service.get_user(id)?;
let greeting = format!("Hello {}!", user.name);
ui.display(greeting);
```

**New Thinking:**
```rust
// CBS approach
let envelope = Envelope::new_request(
    "user_service", "get_user", 
    "user/v1/GetUser", 
    json!({"id": id})
);
let response = bus.request(envelope).await?;
// Handle response through message contract
```

**Key Mental Model Changes:**
1. **Think in messages, not method calls**
2. **Design contracts first, implementation second**
3. **Embrace async-first communication**
4. **Trust the bus for delivery and routing**
5. **Isolate failure domains naturally**

### When to Use CBS

**Perfect for:**
- **Distributed systems** that need to scale
- **Polyglot environments** mixing languages
- **Event-driven architectures**
- **Systems requiring high observability**
- **Microservices that need true independence**
- **Applications with complex state flows**

**Consider alternatives for:**
- Simple CRUD applications
- Single-developer projects
- Systems with tight latency requirements
- Applications with minimal scaling needs

## System Components

### Framework Layer

```
framework/
├── body_core/          # 🧬 Core Contracts
│   ├── Cell trait      # Cell interface definition
│   ├── BodyBus trait   # Message bus interface
│   └── Envelope        # Message wrapper
├── body_bus/           # 🚌 Message Bus Implementation
│   ├── NATS adapter    # Production message bus
│   └── Mock adapter    # Development/testing
├── body/               # 🏗️ Orchestrator
│   ├── App loader      # Application discovery
│   ├── Cell registry   # Cell lifecycle management
│   └── Bus coordinator # Message routing
└── shared_cells/       # 📦 Reusable Components
    ├── rust/           # Rust cell library
    └── dart/           # Dart/Flutter SDK
```

### Application Layer

```
your-project/
├── applications/       # 🎯 Your Applications
│   └── my_app/
│       ├── app.yaml    # Application configuration
│       └── cells/      # Application-specific cells
└── .cbs/               # Framework metadata
```

## Cell Architecture

### Cell Structure
```
cell/
├── ai/spec.md          # 📋 Specification (interface definition)
├── lib/                # 💻 Implementation
├── test/               # 🧪 Tests
└── pubspec.yaml        # 📦 Dependencies (Dart) or Cargo.toml (Rust)
```

### Cell Categories

#### UI Cells (`ui`)
- User interface components
- Flutter widgets, web components
- Handle user interactions
- Publish UI events to bus

#### IO Cells (`io`)
- Input/output operations
- File system, network, stdio
- External data sources
- Protocol adapters

#### Logic Cells (`logic`) 
- Business logic and data processing
- Pure computation
- Stateless transformations
- Domain-specific algorithms

#### Integration Cells (`integration`)
- External service integrations
- API clients
- Database adapters
- Third-party service wrappers

#### Storage Cells (`storage`)
- Data persistence
- Caching layers
- Database operations
- State management

## Message Bus Architecture

### NATS Integration
```
Application → Body → BodyBus → NATS → BodyBus → Cell
```

### Message Flow
1. **Cell publishes** message to subject `cbs.service.verb`
2. **Bus routes** message based on subject pattern
3. **Queue groups** ensure load balancing
4. **Target cell receives** and processes message
5. **Response envelope** sent back with correlation ID

### Envelope Structure
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "service": "greeter",
  "verb": "say_hello",
  "schema": "demo/v1/Name",
  "payload": { 
    "name": "Alice"
  },
  "error": null
}
```

**Envelope Fields Explained:**
- `id`: UUID v4 for correlation tracking across the system
- `service`: Target cell service name (snake_case)
- `verb`: Action to perform (snake_case)
- `schema`: Versioned contract (domain/version/Type)
- `payload`: Actual data (JSON, can be null)
- `error`: Error details if request failed (mutually exclusive with payload)

### Real Example: Greeting Flow

```
1. User Input Cell → Bus: cbs.prompt_name.read {}
   ← Response: {"name": "Alice"}

2. Orchestrator → Bus: cbs.greeter.say_hello {"name": "Alice"}
   ← Response: {"message": "Hello Alice!"}

3. Orchestrator → Bus: cbs.printer.write {"message": "Hello Alice!"}
   ← Response: {"ok": true}
```

Each step is completely independent and can be:
- **Tested in isolation** with mock envelopes
- **Implemented in different languages**
- **Deployed separately**
- **Scaled independently**
- **Monitored individually**

## Practical Development Workflow

### 1. Design Phase: Think in Messages

**Before writing any code:**

1. **Identify the cells** your application needs
   - What capabilities do you need?
   - How should they be isolated?
   - What messages will they exchange?

2. **Design the message contracts**
   ```yaml
   # In ai/spec.md
   Messages:
     cbs.user_service.get_user:
       schema: user/v1/GetUser
       payload: { id: string }
       response: { name: string, email: string }
   ```

3. **Map the message flows**
   ```
   UI → get_user → User Service
   UI ← user_data ← User Service
   UI → render_profile → Profile Cell
   ```

### 2. Implementation Phase: Contract-First

**For each cell:**

1. **Write the spec first** (`ai/spec.md`)
2. **Implement the Cell trait**
3. **Register message handlers**
4. **Test with mock bus**
5. **Integration test with real bus**

**Example Cell Implementation:**
```rust
impl Cell for UserServiceCell {
    fn id(&self) -> &str { "user_service" }
    
    fn subjects(&self) -> Vec<String> {
        vec!["cbs.user_service.get_user".to_string()]
    }
    
    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {
        bus.subscribe("cbs.user_service.get_user", 
            Box::new(|envelope| self.handle_get_user(envelope))
        ).await
    }
}
```

### 3. Integration Phase: Compose Applications

**Create `app.yaml`:**
```yaml
name: my_app
version: 1.0.0
cells:
  - name: user_service
    path: cells/user_service
  - name: profile_ui  
    path: cells/profile_ui
shared_cells:
  - cbs_sdk
```

**Run with CBS framework:**
```bash
body --app my_app
```

### 4. Testing Strategy

**Unit Testing (Cell Level):**
```rust
#[test]
fn test_get_user_handler() {
    let envelope = Envelope::new_request(
        "user_service", "get_user",
        "user/v1/GetUser", 
        json!({"id": "123"})
    );
    
    let result = cell.handle_get_user(envelope).unwrap();
    assert_eq!(result["name"], "Alice");
}
```

**Integration Testing (Bus Level):**
```rust
#[tokio::test]
async fn test_user_flow() {
    let bus = MockBus::new();
    let user_cell = UserServiceCell::new();
    user_cell.register(&bus).await.unwrap();
    
    let response = bus.request(envelope).await.unwrap();
    assert_eq!(response["name"], "Alice");
}
```

## Application Lifecycle

### 1. Discovery Phase
- Body scans `applications/` directory
- Loads `app.yaml` configurations
- Identifies available applications

### 2. Initialization Phase  
- Creates BodyBus instance (NATS or Mock)
- Instantiates cells defined in application
- Registers cells with bus

### 3. Registration Phase
- Each cell calls `register()` with bus
- Subscribes to relevant subjects
- Sets up message handlers

### 4. Runtime Phase
- Cells communicate via message bus
- Body coordinates message routing
- Error handling and logging

### 5. Shutdown Phase
- Graceful cell shutdown
- Bus connection cleanup
- Resource deallocation

## Development Best Practices

### Message Design Guidelines

**Subject Naming:**
- Always use `cbs.{service}.{verb}` format
- Use snake_case for service and verb names
- Be specific: `cbs.user_service.get_profile` not `cbs.user.get`
- Group related verbs under same service

**Schema Versioning:**
- Format: `domain/v{major}/TypeName`
- Examples: `user/v1/Profile`, `payment/v2/Transaction`
- Only bump major version for breaking changes
- Support N-1 versions when possible

**Payload Design:**
- Keep payloads simple and focused
- Use clear, descriptive field names
- Avoid deeply nested structures
- Include all required data (avoid multiple round trips)

**Error Handling:**
```json
{
  "id": "request-uuid",
  "service": "user_service",
  "verb": "get_user",
  "schema": "user/v1/Error",
  "payload": null,
  "error": {
    "code": "UserNotFound",
    "message": "User with ID 123 does not exist",
    "details": {"user_id": "123"}
  }
}
```

### Cell Design Patterns

**Single Responsibility:**
- Each cell should have one clear purpose
- If you need multiple handlers, consider splitting
- Name cells by their capability, not technology

**Stateless Design:**
- Cells should not maintain state between messages
- Use storage cells for persistence
- Pass all required data in messages

**Error Isolation:**
- Cells should handle their own errors gracefully
- Return error envelopes instead of panicking
- Log errors with correlation IDs for tracing

### Common Anti-Patterns

**❌ Don't:**
- Call cell methods directly
- Share objects between cells
- Use global state
- Make cells depend on each other's internal structure
- Skip the message contract design phase

**✅ Do:**
- Communicate only through bus messages
- Design message contracts first
- Keep cells isolated and testable
- Use correlation IDs for request tracing
- Embrace the async nature of message passing

## Framework vs Application Separation

### Framework Responsibilities
- Core contracts and interfaces
- Message bus implementation
- Cell lifecycle management
- Tooling and validation
- Shared cell libraries

### Application Responsibilities  
- Business logic implementation
- Application-specific cells
- Configuration and deployment
- Domain-specific integrations
- User interface components

## Scalability Patterns

### Horizontal Scaling
- Multiple cell instances via NATS queue groups
- Load balancing across cell instances
- Stateless cell design for easy scaling

### Vertical Scaling
- Cell internal optimization
- Async/await patterns
- Resource pooling within cells

### Distributed Scaling
- NATS clustering for high availability
- Cross-region message routing
- Distributed cell deployment

## Error Handling

### Cell-Level Errors
- Cells publish error envelopes on failure
- Structured error messages with correlation IDs
- Graceful degradation patterns

### System-Level Errors
- Bus connection failures handled by Body
- Cell registration errors logged and reported
- Application-level error recovery

### Observability
- Correlation ID tracing across cells
- Structured logging with context
- Metrics collection via NATS monitoring

## Security Model

### Cell Isolation
- No direct cell-to-cell dependencies
- Message-only communication
- Clear trust boundaries

### Message Security
- NATS authentication and authorization
- Envelope signing (future)
- Subject-based access control

### Application Security
- Framework provides security primitives
- Applications implement domain-specific security
- Secure by default configurations

## Performance Characteristics

### Message Overhead
- JSON serialization/deserialization
- NATS network overhead
- Correlation ID tracking

### Optimization Strategies
- Message batching for high throughput
- Connection pooling
- Async processing patterns

### Benchmarking
- Cell processing latency
- Message throughput
- Memory usage patterns

## Future Architecture

### Planned Enhancements
- Hot cell reloading for development
- Visual cell dependency mapping  
- Automatic cell discovery
- Policy-based routing
- Multi-language cell support expansion

## Getting Started

### Quick Start Checklist

1. **✅ Understand the paradigm**: Messages, not method calls
2. **✅ Design your message contracts first**
3. **✅ Implement cells in isolation**
4. **✅ Test with mock bus before integration**
5. **✅ Use correlation IDs for debugging**
6. **✅ Embrace the async nature**
7. **✅ Trust the bus for delivery and scaling**

### Your First CBS Application

```bash
# Create new CBS application
mkdir my_first_app
cd my_first_app

# Create application structure
mkdir -p applications/hello_world/cells/greeter

# Define your app
cat > applications/hello_world/app.yaml << EOF
name: hello_world
version: 1.0.0
description: My first CBS application
cells:
  - name: greeter
    path: cells/greeter
shared_cells: []
EOF

# Run it
body --app hello_world
```

### Next Steps

- Read the [Getting Started Guide](getting-started.md)
- Explore [Framework Usage](framework-usage.md)
- Study the example applications in `examples/`
- Join the community and ask questions

**Remember: CBS is not just a framework, it's a new way of thinking about software architecture. Embrace the biological isolation principle and let the bus handle the complexity!**

