# Master Build Specs Updates

This document lists updates to the CBS Master Build Specs to support multi-app and Flutter web integration.

## Section Updates Required

### Section 1: High-Level Architecture Updates

**Current State:**
- Body loads hardcoded cells in main.rs
- Single application mode only
- Rust-only cell support

**Proposed Changes:**
```markdown
## 1) High-Level Architecture

* **Body (binary crate)**: creates **NATS connection**; loads cells from **body spec configuration**; orchestrates flows; exposes control APIs and **web server**.
* **Body Bus (lib crate)**: NATS message router with subject-based routing; typed envelope.
* **Cells (lib crates)**: single responsibility; subscribe to subjects; publish responses. Support Rust, Dart, Python.
* **Organs**: logical namespaces (e.g., `io.*`, `logic.*`, `ui.*`).
* **Applications**: configured via YAML body spec files defining cells and connections.

**Application Examples:**

1. **CLI Greeter App**: 3 cells
   - `io.prompt_name`: read name → `Name`
   - `logic.greet`: `Name` → `Greeting`
   - `io.print_greeting`: `Greeting` → stdout

2. **Flutter Flow Web App**: 2 cells
   - `ui.flutter_flow`: render "Flow" → `HTML`
   - `web.server`: serve HTTP requests
```

### Section 3: Language Strategy Updates

**Addition:**
```markdown
### 3.1 Flutter Web Integration

**Flutter Web Cells**: Dart cells compiled to JS for web deployment:
- **Compilation**: Flutter web compilation integrated into CBS build
- **Communication**: HTTP/WebSocket bridge between Flutter UI and CBS bus
- **Deployment**: Static web assets served by web server cells
- **Development**: Hot reload for Flutter within CBS

**Web Application Architecture**:
- **Frontend**: Flutter cells render UI and handle interactions
- **Backend**: Rust cells handle logic and integration
- **Bridge**: HTTP API and WebSocket connect layers
- **Deployment**: Single CBS body serves assets and API
```

### Section 4: Repository Layout Updates

**Updated Structure:**
```markdown
## 4) Repository Layout (Workspace)

```
cbs/
├─ Cargo.toml                    # workspace
├─ body/                         # Body (main framework)
│  ├─ src/
│  │  ├─ main.rs
│  │  ├─ config.rs               # Body spec configuration
│  │  └─ web_server.rs           # Web server for Flutter apps
│  └─ tests/integration.rs
├─ body_core/                    # contracts/interfaces
│  └─ src/lib.rs
├─ body_bus/                     # message bus
│  └─ src/lib.rs
├─ apps/                         # Application configurations
│  ├─ cli_greeter_app.yaml
│  ├─ flutter_flow_web_app.yaml
│  └─ body_spec.yaml             # Default configuration
└─ cells/
   ├─ examples/                  # Rust example cells
   │  ├─ greeter_rs/
   │  ├─ io_prompt_name_rs/
   │  ├─ logic_greet_rs/
   │  └─ io_print_greeting_rs/
   ├─ flutter/                   # Flutter/Dart cells
   │  ├─ ui/
   │  │  └─ flow_ui/
   │  └─ web/
   │     └─ server/
   ├─ rust/                      # Additional Rust cells
   │  └─ web/
   │     └─ server/
   └─ python/                    # Python cells (future)
```
```

### Section 5: Crate Contracts Updates

**New 5.5:**
```markdown
### 5.5 `body` Configuration System

* **Purpose**: Dynamic application loading via YAML.
* **Config Loading**: Parse YAML, validate cell references, load cells.
* **Behavior**:
  * Read config from `--app`, env var, or default `body_spec.yaml`
  * Validate paths/dependencies
  * Load/register in dependency order
  * Start web server if Flutter cells present
  * Hot reload (future)

* **Tests**:
  * Parsing/validation
  * Load with valid/invalid paths
  * Dependency ordering
  * App switching
```

### Section 8: Acceptance Criteria Updates

**Updated Criteria:**
```markdown
## 8) Acceptance Criteria (MVP+)

**CLI Application:**
* Prereq: NATS server on `localhost:4222` (or configured)
* `cargo run -p body -- --app apps/cli_greeter_app.yaml` prompts and prints `Hello <name>!`

**Flutter Web Application:**
* `cargo run -p body -- --app apps/flutter_flow_web_app.yaml` starts web server
* `http://localhost:8080` displays "Flow" centered
* Flutter cells talk to CBS via HTTP/WebSocket bridge

**Application Switching:**
* No code changes; config-only
* `cargo run -p body -- --app <config.yaml>` loads different app

**General:**
* `cargo test --workspace` passes with NATS available
* `fmt`/`clippy` clean
* Cells communicate only via NATS or bridge
* Cells are independently add/remove-able
* Distributed-ready: cells can run separately
```

### New Section 15: Application Configuration

```markdown
## 15) Application Configuration System

### 15.1 Body Spec Format

YAML defines which cells to load and how they connect.

**Structure:**
```yaml
application_name: string
version: string
description: string
cells:
  - id: string
    language: rust|dart|python
    path: string
    enabled: boolean
    config: {}
    dependencies: []
flows:
  - name: string
    steps:
      - cell: string
        action: string
```

### 15.2 Application Switching

**Command Line:**
```bash
cargo run -p body -- --app apps/flutter_flow_web_app.yaml
cargo run -p body -- --app apps/cli_greeter_app.yaml
cargo run -p body
```

**Environment Variables:**
```bash
export CBS_APP_CONFIG=apps/flutter_flow_web_app.yaml
cargo run -p body
```

### 15.3 Configuration Validation

* Schema validation
* Path/dependency validation
* Circular dependency detection
* Missing cell error reporting
* Hot reload (future)

### 15.4 Pre-built Applications

**CLI Greeter**
- stdin/stdout demo with Rust cells

**Flutter Flow Web**
- Displays "Flow"; Flutter + Rust web server; browser-accessible
```

### New Section 16: Web Application Support

```markdown
## 16) Web Application Architecture

### 16.1 Flutter Web Integration

Bridge connects Flutter UI cells to CBS bus.

**Components:**
* Flutter Cells (Dart → JS)
* Web Server Cell (Rust HTTP server)
* Message Bridge (HTTP/WebSocket)
* Build Integration (Flutter web compile in CBS)

### 16.2 Communication Patterns

**HTTP API Bridge:**
* POST /api/cbs/request
* GET /api/cbs/subjects
* WebSocket /ws/cbs

**Message Flow:**
1. Flutter UI → envelope
2. Bridge → bus
3. Backend cells process
4. Response → bridge → UI

### 16.3 Development Workflow

```bash
cargo run -p body -- --app apps/flutter_flow_web_app.yaml
open http://localhost:8080
```

**Hot Reload:**
* Flutter hot reload
* CBS cell hot reload (future)
* Config hot reload (future)

### 16.4 Production Deployment

* Single body serves assets and API
* Static asset optimization/caching
* WebSocket management
* Error handling
```

## Implementation Priority

### Phase 1: Basic Configuration System
1. YAML parsing in body
2. CLI arg for config
3. Load cells from config
4. Example configs for CLI greeter

### Phase 2: Flutter Web Foundation
1. Flutter cell framework + CBS integration
2. HTTP/WebSocket bridge
3. Web server cell
4. Basic Flutter Flow UI cell

### Phase 3: Complete Integration
1. Full Flutter Flow app
2. Config validation + errors
3. Hot reload
4. Documentation and examples

## Backward Compatibility

- Existing cells work unchanged
- Defaults preserved when no config specified
- CLI greeter still works
- Tests remain passing

The configuration system is additive and enables powerful composition without breaking existing behavior.
