# {{project_name}}

A Cell Body System (CBS) application built with the CBS framework.

## 🚀 Quick Start

```bash
# Run your application
cargo run -p cbs_body -- --app {{app_name}}

# Run in demo mode
cargo run -p cbs_body -- --app {{app_name}} --demo

# List available applications
cargo run -p cbs_body -- --list-apps

# Run tests
cargo test --workspace
```

## 🏗️ Architecture

This project uses the Cell Body System (CBS) framework for modular, message-driven architecture.

### Applications
- Add your applications in `applications/` directory
- Each application has its own `app.yaml` configuration
- Applications contain cells that communicate via the CBS message bus

### Cells
Cells are organized by category:
- **`ui`** - User interface components
- **`io`** - Input/output operations  
- **`logic`** - Business logic and data processing
- **`integration`** - External service integrations
- **`storage`** - Data persistence and caching

### Message Flow
```
Envelope → Subject: cbs.{service}.{verb} → Queue Group: {service} → Handler → Response
```

## 📚 Documentation

- [CBS Framework Documentation](https://github.com/user/cbs-framework/docs)
- [Cell Development Guide](https://github.com/user/cbs-framework/docs/cell-development.md)
- [Architecture Overview](https://github.com/user/cbs-framework/docs/architecture.md)

## 🛠️ Development

### Adding New Applications
```bash
# Create new application directory
mkdir -p applications/my_app/cells

# Add application configuration
cat > applications/my_app/app.yaml << EOF
application:
  name: my_app
  version: 0.1.0
  type: cli
EOF
```

### Adding New Cells
```bash
# Create new cell
mkdir -p applications/my_app/cells/my_cell/{ai,lib,test}

# Create cell specification
cat > applications/my_app/cells/my_cell/ai/spec.md << EOF
# My Cell Specification
id: my_cell
name: My Cell
version: 1.0.0
language: rust
category: logic
purpose: Brief description of cell's responsibility
EOF
```

## 🧪 Testing

```bash
# Test all cells
cargo test --workspace

# Test specific application
cd applications/my_app && cargo test

# Test specific cell
cd applications/my_app/cells/my_cell && cargo test
```


