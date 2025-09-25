# Cell Body System (CBS) Framework

**CBS** is a **revolutionary framework** for building applications inspired by biological systems. Unlike traditional architectures, cells communicate **only** through a message bus - never directly.

**This is not just another framework - it's a paradigm shift that enables true modularity, language freedom, and natural scaling.**

## 🧬 The CBS Way

**Biological Isolation**: Cells MUST ONLY communicate through the bus
- No direct method calls between cells
- No shared objects or state  
- No imports of other cells
- All communication via typed messages

**Why This Revolutionary Approach Matters**:
- ✅ **Zero coupling** - cells don't know about each other
- ✅ **Polyglot** - mix Rust, Dart, Python naturally
- ✅ **Fault isolation** - cell failures don't cascade
- ✅ **Independent scaling** - scale cells individually
- ✅ **Hot swapping** - replace cells without system restart
- ✅ **Observable** - every interaction is visible

## 🧬 Core Concepts

- **🔬 Cells**: Single-responsibility components that communicate only via message bus
- **🚌 Bus**: NATS-based message system with typed envelopes  
- **📋 Specs**: Machine-readable specifications define cell behavior
- **🏗️ Applications**: Self-contained projects built with CBS cells

## 🚀 Quick Start

### Prerequisites
```bash
# Rust toolchain
curl https://sh.rustup.rs -sSf | sh

# macOS: accept Xcode license to enable linker
sudo xcodebuild -license
```

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

### Communication Rules
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
# Build the framework binaries from repo root
cargo build --workspace

# List apps in the current project directory (expects ./applications here)
./target/debug/body --list-apps

# Run a specific application
./target/debug/body --app my_app

# Demo mode with simulated input
./target/debug/body --app my_app --demo
```

## 📚 Examples

Examples live under `examples/applications/`. The `body` binary scans `./applications` relative to your working directory. For examples, run the binary from `examples/`.

### List available example apps
```bash
# from repo root
cargo build -p body
cd examples
../target/debug/body --list-apps
```

### CLI Greeter (demo)
```bash
cd examples
../target/debug/body --app cli_greeter --demo
```

### Flutter Flow Web (serves prebuilt static assets)
```bash
cd examples
../target/debug/body --app flutter_flow_web
# Open http://localhost:8080
```

Notes:
- No Flutter toolchain needed to run; prebuilt web assets are included.
- Interactive CLI mode is not yet implemented; use `--demo`.

### Troubleshooting (macOS)
```bash
# If you see a linker error about Xcode license, run:
sudo xcodebuild -license
# Then rebuild
cargo build -p body
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

**Start Here:**
- **[The CBS Way](docs/the-cbs-way.md)** - **Read this first!** Understanding the revolutionary approach
- **[Quick Reference](docs/quick-reference.md)** - Essential patterns and examples

**Deep Dive:**
- **[Getting Started](docs/getting-started.md)** - Detailed setup guide
- **[Architecture](docs/architecture.md)** - Framework architecture overview
- **[Framework Usage](docs/framework-usage.md)** - Using CBS as a base framework
- **[Agent-OS Guide](docs/agent-os-guide.md)** - Cell-based development workflow

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