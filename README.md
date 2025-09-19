# Cell Body System (CBS) Framework

**CBS** is a modular framework for building microservice-like applications inspired by biological systems. Build applications as collections of isolated "cells" that communicate through a message bus.

## 🧬 Core Concepts

- **🔬 Cells**: Single-responsibility components that communicate only via message bus
- **🚌 Bus**: NATS-based message system with typed envelopes  
- **📋 Specs**: Machine-readable specifications define cell behavior
- **🏗️ Applications**: Self-contained projects built with CBS cells

## 🚀 Quick Start

### Create New CBS Project

```bash
# Clone CBS framework
git clone https://github.com/user/cbs-framework
cd cbs-framework

# Create new project from template
./tools/cbs-new my-project
cd my-project

# Add your first application
mkdir -p applications/my_app/cells
```

### Add Cells to Your Application

```bash
# Create a new cell
../cbs-framework/tools/cbs-cell create user_service --app my_app --type logic --lang rust

# Build and test
cargo build
cargo test --workspace
```

## 🏗️ Framework Structure

```
cbs-framework/
├── framework/              # 🚀 Core CBS Framework
│   ├── body_core/         # Contracts & traits
│   ├── body_bus/          # NATS message bus
│   ├── body/              # Main orchestrator
│   └── shared_cells/      # Reusable cell library
├── template/              # 📋 Clean Project Template
├── examples/              # 📚 Example Applications
│   ├── cli_greeter/       # CLI greeting example
│   └── flutter_flow_web/  # Flutter web example
├── tools/                 # 🛠️ Framework Tools
│   ├── cbs-new           # Project scaffolding
│   └── cbs-cell          # Cell creation
└── docs/                 # 📖 Framework Documentation
```

## 🎯 Your Project Structure

When you create a new CBS project:

```
my-project/
├── Cargo.toml              # Workspace configuration
├── app.yaml                # Project configuration  
├── applications/           # Your applications
│   └── my_app/
│       ├── app.yaml        # App configuration
│       └── cells/          # App-specific cells
│           └── my_cell/
│               ├── ai/spec.md    # Cell specification
│               ├── lib/          # Implementation
│               └── test/         # Tests
└── .cbs/                   # Framework metadata
```

## 🧬 Cell Architecture

### Cell Categories
- **`ui`** - User interface components (Flutter, web)
- **`io`** - Input/output operations (file, network, stdio)  
- **`logic`** - Business logic and data processing
- **`integration`** - External service integrations (APIs, databases)
- **`storage`** - Data persistence and caching

### Communication Rules [[memory:8924008]]
- **🚌 Bus-Only**: Cells MUST ONLY communicate through the bus
- **🏷️ Typed Messages**: All communication uses typed envelopes
- **📝 Spec-First**: Define interface in `ai/spec.md` before implementation
- **🧪 Test-Driven**: Unit tests for logic, integration tests for bus handling

### Message Format
```
Subject: cbs.{service}.{verb}
Envelope: {
  "schema": "service.verb.v1",
  "payload": { ... },
  "correlation_id": "uuid-v4"
}
```

## 🛠️ Development Tools

### Framework Tools
- **`cbs-new`** - Scaffold new CBS projects
- **`cbs-cell`** - Create new cells with proper structure
- **`cbs-validate`** - Validate CBS compliance (coming soon)

### Running Applications
```bash
# Run specific application
cargo run -p cbs_body -- --app my_app

# Demo mode with simulated input
cargo run -p cbs_body -- --app my_app --demo

# List available applications
cargo run -p cbs_body -- --list-apps
```

## 📚 Examples

### CLI Greeter
Simple command-line application demonstrating cell communication:
```bash
cd examples/cli_greeter
cargo run -p cbs_body -- --app cli_greeter --demo
```

### Flutter Flow Web
Web application built with Flutter cells:
```bash
cd examples/flutter_flow_web
cargo run -p cbs_body -- --app flutter_flow_web
```

## 🧪 Testing Strategy

- **Unit Tests**: Cell logic and behavior
- **Integration Tests**: Message bus communication
- **Application Tests**: End-to-end application flows

```bash
# Test framework
cd framework && cargo test --workspace

# Test your project  
cargo test --workspace

# Test specific cell
cd applications/my_app/cells/my_cell && cargo test
```

## 📖 Documentation

- **[Getting Started](docs/getting-started.md)** - Detailed setup guide
- **[Architecture](docs/architecture.md)** - Framework architecture overview
- **[Cell Development](docs/cell-development.md)** - How to build cells
- **[Message Contracts](docs/message-contracts.md)** - Communication patterns
- **[Best Practices](docs/best-practices.md)** - Development guidelines

## 🔧 Tech Stack

- **Core**: Rust 2021 Edition with Cargo workspace
- **Message Bus**: NATS with JetStream persistence
- **Database**: Supabase PostgreSQL with MCP integration
- **Frontend**: Dart/Flutter for web and mobile
- **Polyglot**: Python support via cells
- **Testing**: Built-in test frameworks for each language

## 🤝 Contributing

1. Fork the CBS framework repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Follow CBS cell standards and principles
4. Add tests for new functionality
5. Submit pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📋 Roadmap

- **✅ Phase 1**: Core framework with Rust cells
- **🚧 Phase 2**: Project templating and tooling  
- **📋 Phase 3**: Polyglot support (Python, Go, TypeScript)
- **📋 Phase 4**: Production features (observability, security)
- **📋 Phase 5**: Advanced features (auto-scaling, self-healing)

## 🧬 Framework Philosophy

- **Spec is Truth**: Behavior defined by machine-readable specifications
- **Biological Isolation**: Cells communicate only via the bus, never directly
- **Polyglot by Design**: Support multiple languages through message contracts
- **Simple Core**: Start small, scale gracefully with clear patterns
- **Test-Driven**: Comprehensive testing at cell, application, and system levels

---

**Ready to build your first CBS application?**

```bash
git clone https://github.com/user/cbs-framework
cd cbs-framework
./tools/cbs-new my-amazing-app
```