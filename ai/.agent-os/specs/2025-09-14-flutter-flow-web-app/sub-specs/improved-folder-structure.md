# Improved Folder Structure - Self-Contained Applications

This document proposes a cleaner folder structure where each application is completely self-contained in its own directory.

## Proposed Directory Structure

```
cbs/
├── Cargo.toml                     # workspace
├── body_core/                     # shared contracts/interfaces
│   └── src/lib.rs
├── body_bus/                      # shared message bus
│   └── src/lib.rs
├── body/                          # main framework binary
│   ├── src/
│   │   ├── main.rs
│   │   └── config.rs              # Application loading logic
│   └── Cargo.toml
├── shared_cells/                  # Reusable cells across applications
│   ├── rust/
│   │   └── web_server/            # HTTP server cell
│   │       ├── SPEC.md
│   │       ├── Cargo.toml
│   │       └── src/lib.rs
│   └── dart/
│       └── cbs_sdk/               # Dart CBS SDK
└── applications/                  # Self-contained applications
    ├── cli_greeter/               # CLI Greeter Application
    │   ├── app.yaml               # Application configuration
    │   ├── README.md              # Application documentation
    │   ├── Cargo.toml             # Application workspace
    │   └── cells/                 # Application-specific cells
    │       ├── io_prompt_name/
    │       │   ├── SPEC.md
    │       │   ├── Cargo.toml
    │       │   └── src/lib.rs
    │       ├── logic_greet/
    │       │   ├── SPEC.md
    │       │   ├── Cargo.toml
    │       │   └── src/lib.rs
    │       └── io_print_greeting/
    │           ├── SPEC.md
    │           ├── Cargo.toml
    │           └── src/lib.rs
    └── flutter_flow_web/          # Flutter Flow Web Application
        ├── app.yaml               # Application configuration
        ├── README.md              # Application documentation
        ├── pubspec.yaml           # Flutter dependencies
        ├── web/                   # Flutter web build output
        │   └── index.html
        └── cells/                 # Application-specific cells
            ├── flow_ui/           # Flutter UI cell
            │   ├── SPEC.md
            │   ├── pubspec.yaml
            │   ├── lib/
            │   │   └── flow_ui.dart
            │   └── web/
            │       └── index.html
            └── api_bridge/        # HTTP/WebSocket bridge cell
                ├── SPEC.md
                ├── Cargo.toml
                └── src/lib.rs
```

## Application Configuration Format

### CLI Greeter App (`applications/cli_greeter/app.yaml`)
```yaml
application:
  name: cli_greeter
  version: 0.1.0
  description: CLI application for greeting users
  type: cli

runtime:
  nats_url: "nats://localhost:4222"
  timeout_ms: 5000

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

# Optional: Reference shared cells
shared_cells:
  - id: web_server
    path: ../../shared_cells/rust/web_server
    enabled: false

flows:
  - name: greeting_flow
    description: Complete greeting interaction
    steps:
      - cell: io_prompt_name
        action: read
      - cell: logic_greet
        action: say_hello
      - cell: io_print_greeting
        action: write
```

### Flutter Flow Web App (`applications/flutter_flow_web/app.yaml`)
```yaml
application:
  name: flutter_flow_web
  version: 0.1.0
  description: Flutter web application displaying 'Flow' text
  type: web

runtime:
  nats_url: "nats://localhost:4222"
  web_server:
    port: 8080
    static_path: ./web

cells:
  - id: flow_ui
    path: ./cells/flow_ui
    language: dart
    config:
      title: "Flow"
      theme: "minimal"
      
  - id: api_bridge
    path: ./cells/api_bridge
    language: rust
    config:
      cors_enabled: true
      websocket_enabled: true

# Use shared web server cell
shared_cells:
  - id: web_server
    path: ../../shared_cells/rust/web_server
    enabled: true
    config:
      port: 8080
      static_path: ./web

flows:
  - name: web_page_render
    description: Render Flow web page
    steps:
      - cell: web_server
        action: serve_request
      - cell: api_bridge
        action: handle_request
      - cell: flow_ui
        action: render_page
```

## Command Line Usage

```bash
# Run CLI greeter application
cargo run -p body -- --app applications/cli_greeter

# Run Flutter web application
cargo run -p body -- --app applications/flutter_flow_web

# List available applications
cargo run -p body -- --list-apps

# Validate application configuration
cargo run -p body -- --app applications/flutter_flow_web --validate
```

## Benefits of This Structure

### 1. **Complete Isolation**
- Each application is completely self-contained
- No mixing of application-specific code
- Clear ownership and responsibility boundaries

### 2. **Easy Application Management**
- Simple to add new applications: create new folder under `applications/`
- Easy to remove applications: delete the folder
- Clear application discovery: list folders in `applications/`

### 3. **Shared Resource Management**
- Common cells in `shared_cells/` can be reused across applications
- Clear distinction between shared and application-specific components
- Version management per application

### 4. **Development Workflow**
- Developers can focus on one application at a time
- Each application can have its own documentation, tests, and configuration
- Independent versioning and deployment

### 5. **Build System Integration**
- Each application can have its own `Cargo.toml` or `pubspec.yaml`
- Application-specific build scripts and configurations
- Clean dependency management

## Application Workspace Structure

### CLI Greeter Application Cargo.toml
```toml
[workspace]
members = [
    "cells/io_prompt_name",
    "cells/logic_greet", 
    "cells/io_print_greeting"
]

[workspace.dependencies]
body_core = { path = "../../body_core" }
tokio = "1.0"
serde_json = "1.0"
async-trait = "0.1"
```

### Flutter Flow Web Application pubspec.yaml
```yaml
name: flutter_flow_web
description: Flutter Flow web application

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.0
  web_socket_channel: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_web_compilers: ^3.0.0

flutter:
  uses-material-design: true
```

## Migration Strategy

### Phase 1: Restructure Existing Code
1. Create `applications/cli_greeter/` directory
2. Move existing example cells to `applications/cli_greeter/cells/`
3. Create `applications/cli_greeter/app.yaml` configuration
4. Update body to load from application directories

### Phase 2: Create Flutter Application
1. Create `applications/flutter_flow_web/` directory
2. Implement Flutter cells in `applications/flutter_flow_web/cells/`
3. Create shared web server cell in `shared_cells/rust/web_server/`
4. Implement application configuration loading

### Phase 3: Enhance Application Management
1. Add application discovery and listing
2. Implement configuration validation
3. Add application templates for easy creation
4. Create development tools and scripts

## Application Template

To make creating new applications easy, we can provide a template generator:

```bash
# Create new application from template
cargo run -p body -- --new-app my_new_app --template web

# This would create:
applications/my_new_app/
├── app.yaml              # Template configuration
├── README.md             # Template documentation  
├── cells/                # Empty cells directory
└── pubspec.yaml          # If web/flutter template
```

This structure makes the CBS system much more organized and maintainable while preserving the core architectural principles of cell isolation and message bus communication.
