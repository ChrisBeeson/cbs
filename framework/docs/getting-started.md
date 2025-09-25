# Getting Started with CBS Framework

> **New to CBS?** Start with [The CBS Way](the-cbs-way.md) to understand the revolutionary approach behind this framework.

This guide will help you create your first Cell Body System (CBS) application.
For the core philosophy, read The CBS Way. For deep design, see Architecture.

## Prerequisites

- **Rust**: 1.70+ with Cargo
- **NATS**: For message bus (optional for development)
- **Git**: For version control

## Installation

### 1. Get CBS Framework

```bash
git clone https://github.com/user/cbs-framework
cd cbs-framework
```

### 2. Create Your First Project

```bash
./tools/cbs-new my-first-app
cd my-first-app
```

This creates a clean CBS project with:
- Framework integration
- Basic configuration
- Empty application structure
- Git repository initialized

## Your First Application

### 1. Create Application Structure

```bash
mkdir -p applications/hello_world/cells
```

### 2. Add Application Configuration

```bash
cat > applications/hello_world/app.yaml << EOF
application:
  name: hello_world
  version: 0.1.0
  description: My first CBS application
  type: cli

runtime:
  nats_url: "nats://localhost:4222"
  timeout_ms: 5000

cells:
  - id: greeter
    path: ./cells/greeter
  - id: printer  
    path: ./cells/printer
EOF
```

### 3. Create Your First Cell

```bash
../cbs-framework/tools/cbs-cell create greeter --app hello_world --type logic --lang rust
```

This scaffolds:
- Cell specification (`.cbs-spec/spec.md`)
- Implementation template (`lib/`)
- Test template (`test/`)
- Build configuration

### 4. Implement the Cell

Edit `applications/hello_world/cells/greeter/lib/greeter.rs`:

```rust
use cbs_framework::{Cell, Envelope, BusError, BodyBus};
use serde::{Deserialize, Serialize};
use async_trait::async_trait;

#[derive(Debug, Serialize, Deserialize)]
pub struct GreeterCell {
    id: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct GreetRequest {
    name: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct GreetResponse {
    message: String,
}

impl GreeterCell {
    pub fn new() -> Self {
        Self {
            id: "greeter".to_string(),
        }
    }
}

#[async_trait]
impl Cell for GreeterCell {
    fn id(&self) -> &str {
        &self.id
    }

    fn subjects(&self) -> Vec<&str> {
        vec!["cbs.greeter.greet"]
    }

    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {
        let cell_id = self.id.clone();
        bus.subscribe("cbs.greeter.greet", Box::new(move |envelope| {
            let cell_id = cell_id.clone();
            Box::pin(async move {
                let request: GreetRequest = envelope.payload_as()?;
                let response = GreetResponse {
                    message: format!("Hello, {}!", request.name),
                };
                envelope.create_response(response)
            })
        })).await
    }
}
```

### 5. Build and Test

```bash
# Build the project
cargo build

# Run tests
cargo test --workspace

# Test your specific cell
cd applications/hello_world/cells/greeter
cargo test
```

### 6. Create a Simple Runner

Add to your main `Cargo.toml` workspace members:
```toml
members = [
    "applications/hello_world/cells/greeter",
    # ... other members
]
```

## Running Your Application

### With NATS Server

```bash
# Start NATS server
docker run -d --name nats-server -p 4222:4222 nats:latest

# Run your application
cargo run -p cbs_body -- --app hello_world
```

### With Mock Bus (Development)

```bash
# Run with mock bus for development
cargo run -p cbs_body -- --app hello_world --mock-bus
```

## Next Steps

### Add More Cells

```bash
# Add an I/O cell for printing
../cbs-framework/tools/cbs-cell create printer --app hello_world --type io --lang rust

# Add a UI cell (if building web app)
../cbs-framework/tools/cbs-cell create web_ui --app hello_world --type ui --lang dart
```

### Explore Examples

```bash
# Look at working examples
cd ../cbs-framework/examples/cli_greeter
cargo run -p cbs_body -- --app cli_greeter --demo

cd ../examples/flutter_flow_web
cargo run -p cbs_body -- --app flutter_flow_web
```

### Learn More

- [The CBS Way](the-cbs-way.md)
- [Architecture](architecture.md)
- [Framework Usage](framework-usage.md)
- [Quick Reference](quick-reference.md)
- [Agent-OS Guide](agent-os-guide.md)

## Common Issues

### Build Errors
```bash
# Clean and rebuild
cargo clean
cargo build
```

### NATS Connection Issues
```bash
# Use mock bus for development
cargo run -p cbs_body -- --app my_app --mock-bus

# Check NATS server
docker logs nats-server
```

### Cell Registration Issues
- Ensure cell implements all required traits
- Check subject naming follows `cbs.{service}.{verb}` pattern
- Verify cell is included in application configuration

## Getting Help

- Review CBS principles in `architecture.md#core-principles`
- Use the Agent-OS commands in `agent-os-guide.md`

