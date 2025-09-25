# Updated Body Spec Configuration Format

This document defines the updated YAML configuration format for self-contained CBS applications.

## Application Directory Structure

Each application is completely self-contained in its own directory under `applications/`:

```
applications/
└── {app_name}/
    ├── app.yaml           # Application configuration
    ├── README.md          # Application documentation
    ├── Cargo.toml         # Rust workspace (if needed)
    ├── pubspec.yaml       # Flutter dependencies (if needed)
    ├── cells/             # Application-specific cells
    │   └── {cell_name}/
    │       ├── SPEC.md
    │       ├── Cargo.toml or pubspec.yaml
    │       └── src/ or lib/
    └── web/               # Static assets (if web app)
```

## Configuration Schema (app.yaml)

```yaml
# Application metadata
application:
  name: string                    # Unique application identifier
  version: string                 # Semantic version
  description: string             # Human-readable description
  type: cli|web|service          # Application type
  created: string                 # ISO 8601 timestamp
  updated: string                 # ISO 8601 timestamp

# Runtime configuration
runtime:
  nats_url: string               # NATS server URL (optional)
  timeout_ms: integer            # Request timeout (optional)
  log_level: debug|info|warn|error # Log level (optional)
  
  # Web-specific runtime config
  web_server:                    # Only for web applications
    port: integer                # HTTP server port
    static_path: string          # Path to static assets
    cors_enabled: boolean        # Enable CORS
    websocket_enabled: boolean   # Enable WebSocket

# Application-specific cells (relative paths)
cells:
  - id: string                   # Unique cell identifier
    path: string                 # Relative path from app directory
    language: rust|dart|python   # Cell implementation language
    enabled: boolean             # Whether cell is active (optional)
    config:                      # Cell-specific configuration (optional)
      key: value
    dependencies: []             # List of cell IDs (optional)

# Shared cells from shared_cells/ directory
shared_cells:
  - id: string                   # Shared cell identifier
    path: string                 # Relative path from cbs root
    enabled: boolean             # Whether to use this shared cell
    config:                      # Override configuration (optional)
      key: value

# Application flows (optional)
flows:
  - name: string                 # Flow name
    description: string          # Flow description
    steps:                       # Ordered cell interactions
      - cell: string             # Cell ID
        action: string           # Action/verb to invoke
        input_schema: string     # Expected input schema (optional)
        output_schema: string    # Expected output schema (optional)

# Environment-specific overrides (optional)
environments:
  development:
    runtime:
      log_level: debug
    cells:
      - id: some_cell
        config:
          debug_mode: true
  production:
    runtime:
      log_level: warn
    shared_cells:
      - id: web_server
        config:
          port: 80
```

## Example Configurations

### CLI Greeter Application
```yaml
# applications/cli_greeter/app.yaml
application:
  name: cli_greeter
  version: 0.1.0
  description: CLI application for greeting users
  type: cli
  created: 2025-09-14T12:00:00Z

runtime:
  nats_url: "nats://localhost:4222"
  timeout_ms: 5000
  log_level: info

cells:
  - id: io_prompt_name
    path: ./cells/io_prompt_name
    language: rust
    
  - id: logic_greet
    path: ./cells/logic_greet
    language: rust
    dependencies:
      - io_prompt_name
    
  - id: io_print_greeting
    path: ./cells/io_print_greeting
    language: rust
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

### Flutter Flow Web Application
```yaml
# applications/flutter_flow_web/app.yaml
application:
  name: flutter_flow_web
  version: 0.1.0
  description: Flutter web application displaying 'Flow' text
  type: web
  created: 2025-09-14T12:00:00Z

runtime:
  nats_url: "nats://localhost:4222"
  timeout_ms: 3000
  log_level: info
  web_server:
    port: 8080
    static_path: ./web
    cors_enabled: true
    websocket_enabled: true

cells:
  - id: flow_ui
    path: ./cells/flow_ui
    language: dart
    config:
      title: "Flow"
      theme: "minimal"
      font_size: "48px"
      
  - id: api_bridge
    path: ./cells/api_bridge
    language: rust
    config:
      cors_origins: ["http://localhost:8080"]
      websocket_path: "/ws/cbs"

shared_cells:
  - id: web_server
    path: ../../shared_cells/rust/web_server
    enabled: true
    config:
      port: 8080
      static_path: ./web
      index_file: "index.html"

flows:
  - name: web_page_render
    description: Render Flow web page
    steps:
      - cell: web_server
        action: serve_request
        input_schema: "web/v1/Request"
        output_schema: "web/v1/Response"
      - cell: api_bridge
        action: handle_api_request
        input_schema: "api/v1/Request"
        output_schema: "api/v1/Response"
      - cell: flow_ui
        action: render_page
        input_schema: "ui/v1/RenderRequest"
        output_schema: "ui/v1/HTML"

environments:
  development:
    runtime:
      log_level: debug
      web_server:
        port: 3000
    cells:
      - id: flow_ui
        config:
          hot_reload: true
          debug_mode: true
  production:
    runtime:
      log_level: warn
      web_server:
        port: 80
    shared_cells:
      - id: web_server
        config:
          gzip_enabled: true
          cache_max_age: 3600
```

## Command Line Interface

### Application Management
```bash
# List available applications
cargo run -p body -- --list-apps

# Run specific application
cargo run -p body -- --app cli_greeter
cargo run -p body -- --app flutter_flow_web

# Run with environment override
cargo run -p body -- --app flutter_flow_web --env production

# Validate application configuration
cargo run -p body -- --app flutter_flow_web --validate

# Create new application from template
cargo run -p body -- --new-app my_app --template web
```

### Environment Variables
```bash
# Set default application
export CBS_DEFAULT_APP=flutter_flow_web

# Set environment
export CBS_ENVIRONMENT=production

# Override configuration directory
export CBS_APPS_DIR=/path/to/applications

# Run with environment variables
cargo run -p body
```

## Path Resolution

### Application Cell Paths
- **Relative to application directory**: `./cells/my_cell`
- **Absolute from CBS root**: `applications/my_app/cells/my_cell`

### Shared Cell Paths  
- **Relative to CBS root**: `../../shared_cells/rust/web_server`
- **Absolute from CBS root**: `shared_cells/rust/web_server`

### Static Asset Paths
- **Relative to application directory**: `./web`, `./assets`
- **Absolute from application directory**: `/Users/user/cbs/applications/my_app/web`

## Configuration Validation

### Required Fields
- `application.name`: Must be unique and match directory name
- `application.version`: Must follow semantic versioning
- `application.type`: Must be one of: cli, web, service
- `cells`: Must contain at least one enabled cell
- `cells[].id`: Must be unique within application
- `cells[].path`: Must point to valid cell directory
- `cells[].language`: Must be supported language

### Path Validation
- All cell paths must exist and contain valid cell structure
- Shared cell paths must exist in `shared_cells/` directory
- Static asset paths must exist for web applications
- Dependency cell IDs must reference existing cells

### Circular Dependency Detection
- Cell dependencies must not create circular references
- Dependencies must form a valid directed acyclic graph (DAG)
- Dependency order affects cell loading sequence

## Application Templates

### CLI Application Template
```bash
cargo run -p body -- --new-app my_cli_app --template cli
```
Creates:
```
applications/my_cli_app/
├── app.yaml              # CLI app configuration
├── README.md             # Template documentation
├── Cargo.toml            # Rust workspace
└── cells/                # Empty cells directory
    └── .gitkeep
```

### Web Application Template
```bash
cargo run -p body -- --new-app my_web_app --template web
```
Creates:
```
applications/my_web_app/
├── app.yaml              # Web app configuration
├── README.md             # Template documentation
├── pubspec.yaml          # Flutter dependencies
├── web/                  # Static assets directory
│   └── index.html        # Template HTML
└── cells/                # Empty cells directory
    └── .gitkeep
```

This configuration format provides complete application isolation while maintaining the flexibility and power of the CBS architecture.
