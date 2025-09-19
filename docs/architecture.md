# CBS Framework Architecture

Cell Body System (CBS) is a modular framework inspired by biological systems where independent cells communicate through a shared message bus.

## Core Principles

### 1. Biological Isolation [[memory:8924008]]
- **Cells MUST ONLY communicate through the bus** - no direct cell-to-cell calls
- Each cell is completely isolated and self-contained
- Cells can be large internally but must expose clean interfaces

### 2. Spec-First Development
- Every cell has `ai/spec.md` defining its interface before implementation
- Specifications are machine-readable and enforceable
- Behavior is predictable and testable

### 3. Single Responsibility
- Each cell performs one clear capability
- Modular design enables reusability and expandability
- Clear separation of concerns

### 4. Typed Contracts
- All messages use typed envelopes with correlation IDs
- Subject format: `cbs.{service}.{verb}`
- Schema versioning for backward compatibility

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
  "schema": "service.verb.v1",
  "payload": { 
    "data": "actual message content"
  },
  "correlation_id": "uuid-v4-string",
  "timestamp": "2024-01-01T12:00:00Z",
  "source": "source_cell_id"
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

