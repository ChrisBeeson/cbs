# Using CBS as a Base Framework

> Read [The CBS Way](the-cbs-way.md) first for the biological isolation principle. Then see [Architecture](architecture.md) for the deeper model.

## The Cardinal Rule: Bus-Only Communication

**CELLS MUST ONLY COMMUNICATE THROUGH THE BUS - NEVER DIRECTLY**

This is not a suggestion - it's an architectural law that enables everything CBS offers. Every example in this guide follows this principle.

This guide explains how to use the Cell Body System (CBS) as a base framework template for building your own applications using message-only architecture.

## Framework vs Application Separation

### What CBS Framework Provides
- **Core Contracts**: Cell trait, BodyBus trait, Envelope types
- **Message Bus**: NATS implementation with mock adapter for testing
- **Orchestration**: Application loading and cell lifecycle management
- **Tooling**: Project scaffolding, cell creation, validation tools
- **Shared Libraries**: Reusable cells (web server, common utilities)

### What Your Application Provides
- **Business Logic**: Domain-specific cells and logic
- **Configuration**: Application-specific settings and deployment
- **UI Components**: User interface cells (Flutter, web, etc.)
- **Integrations**: External service connections and adapters

## Creating a New CBS Project

### Project Setup

Use your preferred workflow to vend a project and reference the framework. Keep framework and app code separate. See examples in the repo; prefer simple, explicit setups.

## Project Structure After Setup

```
my-project/                 # Your project root
├── Cargo.toml             # Workspace with framework dependency
├── app.yaml               # Project configuration
├── README.md              # Project-specific documentation
├── applications/          # Your applications (empty initially)
├── .cbs/                  # Framework metadata
│   ├── framework_version  # CBS version tracking
│   └── README.md         # Framework integration notes
└── framework/             # CBS framework (if using submodule)
    └── ...               # or dependency reference
```

## Building Your First Application

### 1. Create Application Structure

```bash
# Create application directory
mkdir -p applications/my_app/cells

# Create application configuration
cat > applications/my_app/app.yaml << EOF
application:
  name: my_app
  version: 0.1.0
  description: My CBS application
  type: cli

runtime:
  nats_url: "nats://localhost:4222"
  timeout_ms: 5000

cells:
  - id: main_logic
    path: ./cells/main_logic
EOF
```

### 2. Add Cells to Your Application

```bash
# Using CBS tooling (if framework is adjacent)
../cbs-framework/tools/cbs-cell create main_logic --app my_app --type logic --lang rust

# Or manually create cell structure
mkdir -p applications/my_app/cells/main_logic/{ai,lib,test}
```

### 3. Update Workspace Configuration

Add your cells to the main `Cargo.toml`:

```toml
[workspace]
members = [
    "applications/my_app/cells/main_logic",
    # Add other cells here
]

[workspace.dependencies]
cbs_framework = { path = "./framework/framework" }  # or version from crates.io
# ... other dependencies
```

## Framework Integration Patterns

### Pattern 1: Framework as Dependency

```toml
# Cargo.toml
[dependencies]
cbs_framework = "0.1.0"  # From crates.io when published
```

**Pros**: Clean dependency management, automatic updates
**Cons**: Less control over framework changes

### Pattern 2: Framework as Submodule

```bash
git submodule add https://github.com/user/cbs-framework framework
```

**Pros**: Full control, can modify framework, pin specific versions
**Cons**: More complex git workflow, manual updates

### Pattern 3: Framework Fork

```bash
# Fork CBS framework repository
# Clone your fork
git clone https://github.com/youruser/cbs-framework my-project
# Remove example applications, keep framework
```

**Pros**: Maximum control, can customize framework
**Cons**: Maintenance overhead, harder to get upstream updates

## Development Workflow

### Daily Development

```bash
# Add new cells
./framework/tools/cbs-cell create new_feature --app my_app --type logic --lang rust

# Build and test
cargo build
cargo test --workspace

# Run your application
cargo run -p cbs_body -- --app my_app
```

### Framework Updates

#### With Dependency Pattern
```bash
# Update Cargo.toml version
cbs_framework = "0.2.0"
cargo update
```

#### With Submodule Pattern  
```bash
cd framework
git pull origin main
cd ..
git add framework
git commit -m "Update CBS framework to v0.2.0"
```

### Testing Strategy

```bash
# Test framework integration
cargo test -p cbs_framework

# Test your cells
cd applications/my_app/cells/my_cell
cargo test

# Integration tests
cargo test --workspace
```

## Configuration Management

### Project Configuration (`app.yaml`)

```yaml
project:
  name: "my-project"
  version: "1.0.0"
  description: "My CBS application"

framework:
  cbs_version: "0.1.0"
  nats_url: "nats://localhost:4222"

# Environment-specific settings
environments:
  development:
    mock_bus: true
    debug: true
  production:
    mock_bus: false
    debug: false
```

### Application Configuration (`applications/my_app/app.yaml`)

```yaml
application:
  name: my_app
  version: 1.0.0
  type: web

runtime:
  port: 8080
  workers: 4

cells:
  - id: web_server
    path: ./cells/web_server
    config:
      port: 8080
  - id: api_handler  
    path: ./cells/api_handler
```

## Best Practices

### 1. Keep Framework and Application Separate
- Don't modify framework code directly in your project
- Use configuration and cell implementations for customization
- Contribute framework improvements back upstream

### 2. Version Management
- Pin framework versions in production
- Test framework updates in development first
- Keep track of breaking changes

### 3. Cell Design
- Follow CBS isolation principles [[memory:8924008]]
- Define clear interfaces in `.cbs-spec/spec.md`
- Write comprehensive tests

### 4. Documentation
- Update project README with your specific setup
- Document any framework customizations
- Keep cell specifications current

## Migration and Upgrades

### Upgrading Framework Versions

1. **Check Breaking Changes**: Review framework changelog
2. **Update Dependencies**: Modify Cargo.toml or submodule
3. **Test Compatibility**: Run full test suite
4. **Update Specs**: Modify cell specifications if needed
5. **Deploy Gradually**: Use feature flags for large changes

### Migrating Existing Projects

1. **Audit Current Structure**: Identify framework vs application code
2. **Extract Business Logic**: Move application cells to new structure  
3. **Update Dependencies**: Point to CBS framework
4. **Test Integration**: Ensure all cells work with framework
5. **Update Documentation**: Reflect new structure

## Troubleshooting

### Common Issues

#### Framework Not Found
```bash
# Check dependency path
grep -r "cbs_framework" Cargo.toml

# Verify framework location
ls -la framework/
```

#### Cell Registration Errors
- Ensure cell implements Cell trait correctly
- Check subject naming follows `cbs.{service}.{verb}` pattern
- Verify cell is listed in application configuration

#### Build Errors
```bash
# Clean and rebuild
cargo clean
cargo build

# Check workspace members
cargo tree
```

### Getting Help

1. **Check Examples**: Look at `framework/examples/` directory
2. **Review Documentation**: Framework docs in `framework/docs/`
3. **Validate Structure**: Use CBS validation tools
4. **Community Support**: Framework repository issues/discussions

## Future Considerations

### Framework Evolution
- CBS evolves; follow changelogs and migration notes

### Contribution Opportunities
- Contribute reusable cells to `shared_cells/`
- Improve framework tooling and documentation
- Share patterns and best practices with community

