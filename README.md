# Cell Body System (CBS) — MVP

The **Cell Body System (CBS)** is a modular framework for building microservice-like applications inspired by biological systems.

At its heart:

* **Cells**: the smallest unit of work. Each does *one task and one task well*.
* **Body**: orchestrates cells and owns the **Body Bus** (message bus).
* **Envelopes**: typed messages that carry requests and responses.
* **Specs**: every cell has a spec (its "DNA"), making behaviour testable, reproducible, and replaceable.

The MVP demonstrates this concept with Rust cells connected via message passing, with NATS support for distributed scaling.

## 🚀 Quick Start

### CLI Greeter Application

```bash
# Run the CLI greeter application
cargo run -p body -- --app cli_greeter

# Or run in demo mode (simulated input)
cargo run -p body -- --app cli_greeter --demo
```

### Flutter Flow Web Application

```bash
# Run the Flutter web application (when implemented)
cargo run -p body -- --app flutter_flow_web

# Access the web app at http://localhost:8080
```

### Default Mode (Legacy)

```bash
# Run default mode (backwards compatibility)
cargo run -p body

# Run in demo mode
cargo run -p body -- --demo
```

### List Available Applications

```bash
# See all available applications
cargo run -p body -- --list-apps
```

### Run Tests

```bash
# Test all implemented components
cargo test -p body_core -p greeter_rs -p logic_greet_rs -p io_prompt_name_rs -p io_print_greeting_rs -p body
```

## 🎯 What You'll See

The MVP demo orchestrates three cells in sequence:

1. **📝 PromptName** — reads a name from stdin (or simulates in demo mode)
2. **🤖 LogicGreet** — formats a greeting with timestamp
3. **🖨️ Printer** — outputs the greeting to stdout

Example demo run:
```
🧬 Cell Body System (CBS) - MVP Demo
=====================================
Running in demo mode...

1. 📝 Prompting for name (simulated)...
   Input: Ada Lovelace

2. 🤖 Processing greeting...
   Generated: Hello Ada Lovelace!

3. 🖨️  Printing greeting...
Hello Ada Lovelace!

✅ Demo completed successfully!
```

## 🏗️ Architecture

### Core Components

- **`body_core`** - Core contracts (Envelope, BusError, BodyBus, Cell traits)
- **`body_bus`** - NATS-based message bus implementation  
- **`body`** - Main orchestrator binary with application loading
- **Applications** - Self-contained application directories:
  - `applications/cli_greeter/` - CLI greeting application
  - `applications/flutter_flow_web/` - Flutter web application (planned)
- **Shared Cells** - Reusable components in `shared_cells/`:
  - `shared_cells/rust/web_server/` - HTTP server cell
  - `shared_cells/dart/cbs_sdk/` - Dart CBS SDK

### Message Flow

```
Envelope → Subject: cbs.{service}.{verb} → Queue Group: {service} → Handler → Response
```

All communication uses typed JSON envelopes with correlation IDs for tracing.

## 🧪 Testing Strategy

- **Unit Tests**: 55 tests across all components
- **Component Tests**: Cell behavior with mocked I/O
- **Integration Tests**: End-to-end flows (NATS-dependent)

Current test coverage:
- ✅ Core contracts (9 tests)
- ✅ All cells (35+ tests) 
- ✅ Body framework (6 tests)
- ✅ MockBus integration (fully functional message bus)

## 📚 Documentation

### Architecture & Specs
* **Master Spec** → [`ai/master_build_specs.md`](ai/master_build_specs.md)
* **Data Flows** → [`ai/docs/data_flows.md`](ai/docs/data_flows.md)
* **Product Mission** → [`.agent-os/product/mission.md`](.agent-os/product/mission.md)
* **Technical Stack** → [`.agent-os/product/tech-stack.md`](.agent-os/product/tech-stack.md)
* **Development Roadmap** → [`.agent-os/product/roadmap.md`](.agent-os/product/roadmap.md)

### Development Guidelines
* **LLM Tripwires** → [`ai/docs/llm_tripwires.md`](ai/docs/llm_tripwires.md)
* **Error Codes** → [`ai/docs/error_codes.md`](ai/docs/error_codes.md)
* **Agent OS Standards** → [`ai/docs/agent_os_standards.md`](ai/docs/agent_os_standards.md)

### Schema & Validation
* **Envelope Schema** → [`ai/docs/schemas/envelope.schema.json`](ai/docs/schemas/envelope.schema.json)
* **Validation Script** → [`ai/scripts/validate_envelopes.sh`](ai/scripts/validate_envelopes.sh)

## ⚙️ Configuration

### Command Line Options

```bash
body [OPTIONS]

OPTIONS:
    --app <APP_NAME>    Application to run (e.g., cli_greeter, flutter_flow_web)
    --list-apps         List all available applications
    --nats-url <URL>    NATS server URL (default: nats://localhost:4222)
    --demo              Run in demo mode with simulated input
    --mock-bus          Use mock bus instead of NATS (for testing)
    --env <ENV>         Environment override (development, production)
    --validate          Validate application configuration
    -h, --help          Print help message
```

### Environment Variables

```bash
CBS_DEFAULT_APP=cli_greeter       # Default application to run
CBS_APPS_DIR=./applications       # Applications directory
CBS_ENVIRONMENT=development       # Environment (development, production)
NATS_URL=nats://localhost:4222    # NATS server URL
CBS_DEMO_MODE=1                   # Enable demo mode
CBS_MOCK_BUS=1                    # Use mock bus
```

## 🚧 Current Status

### ✅ Completed (MVP)
- [x] Core contracts with comprehensive tests
- [x] Four example cells with full test coverage
- [x] Body framework with orchestration
- [x] Configuration and CLI interface
- [x] Demo mode and interactive mode
- [x] Complete documentation

### ⚠️ Known Issues
- NATS integration blocked by Cargo version incompatibility with `async-nats` dependencies
- **Resolved**: Functional MockBus implementation provides full message bus capabilities for MVP
- Full distributed NATS mode available when compatible Rust toolchain is used

### 🔄 Next Steps
1. Implement self-contained application system
2. Create Flutter Flow web application
3. Add application configuration validation
4. Implement shared cell system
5. Add hot reloading for development

## 🗺️ Roadmap

* **Phase 1 (MVP)**: ✅ Rust cells + message bus + orchestration
* **Phase 2**: 🚧 Self-contained applications + Flutter web support
* **Phase 3**: Polyglot support (Python/Dart cells)
* **Phase 4**: Production features (JetStream, observability, security)
* **Phase 5**: Advanced features (auto-scaling, self-healing)
* **Phase 6**: Enterprise platform (governance, compliance, marketplace)

## 🧬 Principles

* **Spec is truth** — behavior defined by machine-readable specs
* **Isolation** — cells communicate only via the bus
* **Polyglot** — designed for Rust, Python, Dart (others via adapters)
* **Simple core** — start small, scale gracefully
* **Test-driven** — comprehensive test coverage at all levels

## 🤝 Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for development guidelines and [`ai/docs/agent_os_standards.md`](ai/docs/agent_os_standards.md) for coding standards.

## 🔧 Troubleshooting

### NATS Connection Issues

If you encounter NATS-related errors:

1. **Dependency Conflicts**: Current Cargo version (1.80.0-nightly) incompatible with `async-nats` dependencies requiring `edition2024`
   - **Workaround**: Use demo mode (`--demo`) or mock bus (`--mock-bus`)
   - **Solution**: Update to compatible Cargo version when available

2. **NATS Server Not Running**: 
   ```bash
   # Start NATS server
   docker run -d --name nats-server -p 4222:4222 nats:latest
   
   # Verify it's running
   docker logs nats-server
   ```

3. **Port Conflicts**: 
   ```bash
   # Use different port
   docker run -d --name nats-server -p 4223:4222 nats:latest
   cargo run -p body -- --nats-url nats://localhost:4223
   ```

### Build Issues

```bash
# Clean and rebuild
cargo clean
cargo build

# Test without NATS dependencies
cargo test -p body_core -p greeter_rs -p logic_greet_rs -p io_prompt_name_rs -p io_print_greeting_rs -p body
```