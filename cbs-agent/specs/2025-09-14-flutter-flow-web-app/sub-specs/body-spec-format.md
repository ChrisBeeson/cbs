# Body Spec Configuration Format

This defines the YAML format for CBS body specs enabling application switching.

## Schema Definition

```yaml
# app.yaml - CBS Application Configuration
application_name: string          # Unique application identifier
version: string                   # Semantic version (e.g., "0.1.0")
description: string               # Human-readable description
created: string                   # ISO 8601 timestamp
updated: string                   # ISO 8601 timestamp

# Runtime configuration
runtime:
  nats_url: string               # NATS URL (default localhost:4222)
  timeout_ms: integer            # Request timeout ms (default 5000)
  max_retries: integer           # Max retry attempts (default 3)
  log_level: string              # debug|info|warn|error (default info)

# Cell definitions
cells:
  - id: string                   # Unique cell identifier
    name: string                 # Human-readable
    language: string             # rust|dart|python
    path: string                 # Relative path
    enabled: boolean             # default true
    config:                      # Optional
      key: value
    dependencies: []             # Optional
    
# Application flows (optional)
flows:
  - name: string
    description: string  
    steps:
      - cell: string
        action: string
        input_schema: string
        output_schema: string

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
# applications/flutter_flow_web/app.yaml
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
    path: ./cells/flow_ui
    enabled: true
    config:
      title: "Flow"
      theme: "minimal"
  - id: web_server
    name: Web Server
    language: rust  
    path: ../../shared_cells/rust/web_server
    enabled: true
    config:
      port: 8080
      static_path: "./web/build"

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
# applications/cli_greeter/app.yaml
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
    path: ./cells/io_prompt_name_rs
    enabled: true
  - id: logic_greet
    name: Greeting Logic
    language: rust
    path: ./cells/logic_greet_rs
    enabled: true
    dependencies:
      - io_prompt_name
  - id: io_print_greeting
    name: Greeting Printer
    language: rust
    path: ./cells/io_print_greeting_rs
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

### Command Line
```bash
cargo run -p body -- --app applications/flutter_flow_web
cargo run -p body
cargo run -p body -- --app applications/flutter_flow_web --env production
```

### Environment Variables
```bash
export CBS_APP_CONFIG=applications/flutter_flow_web
export CBS_ENVIRONMENT=development
export CBS_LOG_LEVEL=debug
cargo run -p body
```

### Configuration Directory
```
cbs/
├── applications/
│   ├── flutter_flow_web/
│   │   └── app.yaml
│   ├── cli_greeter/
│   │   └── app.yaml
│   └── multi_cell_demo/
│       └── app.yaml
└── body/src/config.rs
```

## Validation Rules

### Required
- `application_name` unique, kebab-case
- `version` semver
- `cells` has at least one enabled
- `cells[].id` unique
- `cells[].language` in rust|dart|python
- `cells[].path` valid directory

### Optional
- Sensible defaults for `runtime`
- `flows` recommended for docs
- `environments` for overrides
- `config` and `dependencies` optional

### Dependency Validation
- Dependencies reference existing IDs
- No cycles
- Order impacts load sequence

## Migration Strategy

### Phase 1: Basic Loading
- YAML parsing and validation
- Load cells from config
- Basic error handling

### Phase 2: Advanced
- Environment overrides
- Flow validation
- Hot reload

### Phase 3: Production
- Versioning/rollback
- Distributed config management
- Advanced validation/testing tools
