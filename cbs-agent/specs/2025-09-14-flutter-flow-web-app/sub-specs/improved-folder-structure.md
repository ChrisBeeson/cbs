# Improved Folder Structure - Self-Contained Applications

This proposes a structure where each application is fully self-contained.

## Proposed Directory Structure

```
cbs/
├── Cargo.toml                     # workspace
├── body_core/                     # shared contracts/interfaces
│   └── src/lib.rs
├── body_bus/                      # message bus
│   └── src/lib.rs
├── body/                          # main framework
│   ├── src/
│   │   ├── main.rs
│   │   └── config.rs              # Application loading
│   └── Cargo.toml
├── shared_cells/                  # Reusable cells
│   ├── rust/
│   │   └── web_server/
│   │       ├── SPEC.md
│   │       ├── Cargo.toml
│   │       └── src/lib.rs
│   └── dart/
│       └── cbs_sdk/
└── applications/                  # Self-contained apps
    ├── cli_greeter/
    │   ├── app.yaml
    │   ├── README.md
    │   ├── Cargo.toml
    │   └── cells/
    │       ├── io_prompt_name/
    │       ├── logic_greet/
    │       └── io_print_greeting/
    └── flutter_flow_web/
        ├── app.yaml
        ├── README.md
        ├── pubspec.yaml
        ├── web/
        │   └── index.html
        └── cells/
            ├── flow_ui/
            │   ├── SPEC.md
            │   ├── pubspec.yaml
            │   └── lib/flow_ui.dart
            └── api_bridge/
                ├── SPEC.md
                ├── Cargo.toml
                └── src/lib.rs
```

## Application Configuration Format

### CLI Greeter (`applications/cli_greeter/app.yaml`)
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

### Flutter Flow Web (`applications/flutter_flow_web/app.yaml`)
```yaml
application:
  name: flutter_flow_web
  version: 0.1.0
  description: Flutter web application displaying 'Flow'
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
cargo run -p body -- --app applications/cli_greeter
cargo run -p body -- --app applications/flutter_flow_web
cargo run -p body -- --list-apps
cargo run -p body -- --app applications/flutter_flow_web --validate
```

## Benefits

1. **Isolation**: Each app is self-contained; clear ownership.
2. **Management**: Add/remove apps by folder; easy discovery.
3. **Sharing**: `shared_cells/` for reuse across apps.
4. **Workflow**: Per-app docs, tests, config, versioning.
5. **Build**: Per-app manifests and build scripts.

## Application Workspace Examples

### CLI Greeter `Cargo.toml`
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

### Flutter Flow Web `pubspec.yaml`
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

### Phase 1: Restructure
1. Create `applications/cli_greeter/`
2. Move example cells under `applications/cli_greeter/cells/`
3. Create `applications/cli_greeter/app.yaml`
4. Update body to load from app directories

### Phase 2: Create Flutter App
1. Create `applications/flutter_flow_web/`
2. Implement Flutter cells under `applications/flutter_flow_web/cells/`
3. Create `shared_cells/rust/web_server/`
4. Implement config loading

### Phase 3: Enhance Management
1. App discovery/listing
2. Config validation
3. App templates
4. Dev tools and scripts

## Application Template

```bash
cargo run -p body -- --new-app my_new_app --template web
# creates applications/my_new_app/ with app.yaml, README.md, cells/, pubspec.yaml (if web)
```

This structure keeps CBS organized and maintainable while preserving cell isolation and bus communication.
