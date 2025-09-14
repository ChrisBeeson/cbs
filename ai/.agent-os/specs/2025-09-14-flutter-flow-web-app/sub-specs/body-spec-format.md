# Body Spec Configuration Format

This document defines the YAML configuration format for CBS body specifications that enable application switching.

## Schema Definition

```yaml
# body_spec.yaml - CBS Application Configuration
application_name: string          # Unique application identifier
version: string                   # Semantic version (e.g., "0.1.0")
description: string               # Human-readable description
created: string                   # ISO 8601 timestamp
updated: string                   # ISO 8601 timestamp

# Runtime configuration
runtime:
  nats_url: string               # NATS server URL (optional, defaults to localhost:4222)
  timeout_ms: integer            # Request timeout in milliseconds (optional, default 5000)
  max_retries: integer           # Maximum retry attempts (optional, default 3)
  log_level: string              # Log level: debug|info|warn|error (optional, default info)

# Cell definitions
cells:
  - id: string                   # Unique cell identifier
    name: string                 # Human-readable cell name
    language: string             # rust|dart|python
    path: string                 # Relative path to cell directory
    enabled: boolean             # Whether cell is active (optional, default true)
    config:                      # Cell-specific configuration (optional)
      key: value                 # Arbitrary key-value pairs
    dependencies: []             # List of cell IDs this cell depends on (optional)
    
# Application flows (optional)
flows:
  - name: string                 # Flow name
    description: string          # Flow description  
    steps:                       # Ordered list of cell interactions
      - cell: string             # Cell ID
        action: string           # Action/verb to invoke
        input_schema: string     # Expected input schema
        output_schema: string    # Expected output schema

# Environment-specific overrides (optional)
environments:
  development:
    runtime:
      log_level: debug
      nats_url: "nats://localhost:4222"
  production:
    runtime:
      log_level: info
      nats_url: "nats://prod-nats:4222"
```

## Example Configurations

### Flutter Flow Web App
```yaml
# apps/flutter_flow_web_app.yaml
application_name: flutter_flow_web_app
version: 0.1.0
description: Flutter web application displaying 'Flow' text
created: 2025-09-14T12:00:00Z
updated: 2025-09-14T12:00:00Z

runtime:
  timeout_ms: 3000
  log_level: info

cells:
  - id: flutter_flow_ui
    name: Flow UI Renderer
    language: dart
    path: cells/flutter/ui/flow_ui
    enabled: true
    config:
      title: "Flow"
      theme: "minimal"
      
  - id: web_server
    name: Web Server
    language: rust  
    path: cells/rust/web/server
    enabled: true
    config:
      port: 8080
      static_path: "web/build"

flows:
  - name: web_page_render
    description: Render Flow web page
    steps:
      - cell: web_server
        action: serve_request
        input_schema: "web/v1/Request"
        output_schema: "web/v1/Response"
      - cell: flutter_flow_ui
        action: render_page
        input_schema: "ui/v1/RenderRequest"
        output_schema: "ui/v1/HTML"
```

### CLI Greeter App
```yaml
# apps/cli_greeter_app.yaml
application_name: cli_greeter_app
version: 0.1.0
description: CLI application for greeting users
created: 2025-09-14T12:00:00Z
updated: 2025-09-14T12:00:00Z

runtime:
  timeout_ms: 5000
  log_level: info

cells:
  - id: io_prompt_name
    name: Name Prompter
    language: rust
    path: cells/examples/io_prompt_name_rs
    enabled: true
    
  - id: logic_greet
    name: Greeting Logic
    language: rust
    path: cells/examples/logic_greet_rs
    enabled: true
    dependencies:
      - io_prompt_name
    
  - id: io_print_greeting
    name: Greeting Printer
    language: rust
    path: cells/examples/io_print_greeting_rs
    enabled: true
    dependencies:
      - logic_greet

flows:
  - name: greeting_flow
    description: Complete greeting interaction
    steps:
      - cell: io_prompt_name
        action: read
        input_schema: "demo/v1/Void"
        output_schema: "demo/v1/Name"
      - cell: logic_greet
        action: say_hello
        input_schema: "demo/v1/Name"
        output_schema: "demo/v1/Greeting"
      - cell: io_print_greeting
        action: write
        input_schema: "demo/v1/Message"
        output_schema: "demo/v1/Void"
```

## Configuration Loading

### Command Line Usage
```bash
# Load specific application configuration
cargo run -p body -- --app apps/flutter_flow_web_app.yaml

# Use default configuration (body_spec.yaml)
cargo run -p body

# Override environment
cargo run -p body -- --app apps/flutter_flow_web_app.yaml --env production
```

### Environment Variables
```bash
export CBS_APP_CONFIG=apps/flutter_flow_web_app.yaml
export CBS_ENVIRONMENT=development
export CBS_LOG_LEVEL=debug
cargo run -p body
```

### Configuration Directory Structure
```
cbs/
├── apps/                          # Application configurations
│   ├── flutter_flow_web_app.yaml  # Flutter web app config
│   ├── cli_greeter_app.yaml       # CLI greeter app config
│   └── multi_cell_demo.yaml       # Multi-cell demo config
├── body_spec.yaml                 # Default configuration
└── body/
    └── src/
        └── config.rs              # Configuration loading logic
```

## Validation Rules

### Required Fields
- `application_name`: Must be unique and follow kebab-case
- `version`: Must follow semantic versioning (major.minor.patch)
- `cells`: Must contain at least one enabled cell
- `cells[].id`: Must be unique within the configuration
- `cells[].language`: Must be one of: rust, dart, python
- `cells[].path`: Must point to valid cell directory

### Optional Fields
- All `runtime` settings have sensible defaults
- `flows` section is optional but recommended for documentation
- `environments` section enables environment-specific overrides
- Cell `config` and `dependencies` are optional

### Dependency Validation
- Cell dependencies must reference existing cell IDs
- Circular dependencies are not allowed
- Dependency order affects cell loading sequence

## Migration Strategy

### Phase 1: Basic Configuration Loading
- Implement YAML parsing and validation
- Support cell loading from configuration
- Basic error handling and validation

### Phase 2: Advanced Features  
- Environment-specific overrides
- Flow definitions and validation
- Hot reloading of configurations

### Phase 3: Production Features
- Configuration versioning and rollback
- Distributed configuration management
- Advanced validation and testing tools
