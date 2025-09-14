# Master Build Specs Updates

This document outlines the necessary updates to the CBS Master Build Specs to support multiple applications and Flutter web integration.

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
* **Body Bus (lib crate)**: NATS-based message router with subject-based routing. Contract-driven, typed envelope.
* **Cells (lib crates)**: single responsibility; subscribe to NATS subjects; publish responses. **Support Rust, Dart, and Python**.
* **Organs**: logical namespaces (e.g., `io.*`, `logic.*`, `ui.*`) mapped to NATS subject hierarchies.
* **Applications**: configured via **body spec YAML files** that define which cells to load and how they connect.

**Application Examples:**

1. **CLI Greeter App**: 3 cells
   - `io.prompt_name`: read name from stdin → `Name`
   - `logic.greet`: `Name` → `Greeting` 
   - `io.print_greeting`: `Greeting` → stdout

2. **Flutter Flow Web App**: 2 cells
   - `ui.flutter_flow`: render "Flow" web page → `HTML`
   - `web.server`: serve HTTP requests → web responses
```

### Section 3: Language Strategy Updates

**Addition to Existing Content:**
```markdown
### 3.1 Flutter Web Integration

**Flutter Web Cells**: Dart-based cells that compile to JavaScript for web deployment:
- **Compilation**: Flutter web compilation integrated into CBS build system
- **Communication**: HTTP/WebSocket bridge between Flutter UI and CBS message bus
- **Deployment**: Static web assets served by CBS web server cells
- **Development**: Hot reload support for rapid Flutter development within CBS

**Web Application Architecture**:
- **Frontend**: Flutter web cells handle UI rendering and user interactions
- **Backend**: Rust cells handle business logic, data processing, and system integration
- **Bridge**: HTTP API and WebSocket connections enable seamless communication
- **Deployment**: Single CBS body serves both web assets and API endpoints
```

### Section 4: Repository Layout Updates

**Updated Structure:**
```markdown
## 4) Repository Layout (Workspace)

```
cbs/
├─ Cargo.toml                    # workspace
├─ body/                         # binary: Body (main framework)
│  ├─ src/
│  │  ├─ main.rs
│  │  ├─ config.rs               # Body spec configuration loading
│  │  └─ web_server.rs           # Web server for Flutter apps
│  └─ tests/integration.rs
├─ body_core/                    # contracts/interfaces shared
│  └─ src/lib.rs
├─ body_bus/                     # message bus implementation
│  └─ src/lib.rs
├─ apps/                         # Application configurations
│  ├─ cli_greeter_app.yaml       # CLI greeter configuration
│  ├─ flutter_flow_web_app.yaml  # Flutter web app configuration
│  └─ body_spec.yaml             # Default configuration
└─ cells/
   ├─ examples/                  # Rust example cells
   │  ├─ greeter_rs/
   │  ├─ io_prompt_name_rs/
   │  ├─ logic_greet_rs/
   │  └─ io_print_greeting_rs/
   ├─ flutter/                   # Flutter/Dart cells
   │  ├─ ui/
   │  │  └─ flow_ui/             # Flow display cell
   │  └─ web/
   │     └─ server/              # Web server cell
   ├─ rust/                      # Additional Rust cells
   │  └─ web/
   │     └─ server/              # HTTP server cell
   └─ python/                    # Python cells (future)
```
```

### Section 5: Crate Contracts Updates

**New Section 5.5:**
```markdown
### 5.5 `body` Configuration System

* **Purpose**: Dynamic application loading via YAML configuration files.
* **Config Loading**: Parse body spec YAML, validate cell references, load specified cells.
* **Behavior**:
  * Read configuration from `--app` flag, environment variable, or default `body_spec.yaml`
  * Validate cell paths and dependencies exist
  * Load and register cells in dependency order
  * Start web server if Flutter cells are present
  * Support configuration hot reloading (future)

* **Tests**:
  * Configuration parsing and validation
  * Cell loading with valid and invalid paths
  * Dependency resolution and ordering
  * Application switching between different configurations
```

### Section 8: Acceptance Criteria Updates

**Updated Criteria:**
```markdown
## 8) Acceptance Criteria (MVP+)

**CLI Application:**
* **Prerequisites**: NATS server running on `localhost:4222` (or configured URL).
* `cargo run -p body -- --app apps/cli_greeter_app.yaml` prompts for name and prints `Hello <name>!` via NATS messaging.

**Flutter Web Application:**
* `cargo run -p body -- --app apps/flutter_flow_web_app.yaml` starts web server and serves Flutter app.
* Navigating to `http://localhost:8080` displays "Flow" centered on the page.
* Flutter cells communicate with CBS backend via HTTP/WebSocket bridge.

**Application Switching:**
* Switching between configurations requires no code changes, only configuration file updates.
* `cargo run -p body -- --app <different_config.yaml>` loads completely different application.

**General Requirements:**
* All tests pass (`cargo test --workspace`) with NATS server available.
* Lints clean (`fmt`/`clippy` pass).
* Cells communicate **only** via NATS subjects or HTTP/WebSocket bridge.
* Adding/removing a cell requires **no** changes to others.
* **Distributed ready**: cells can run on separate processes/machines.
```

### New Section 15: Application Configuration

```markdown
## 15) Application Configuration System

### 15.1 Body Spec Format

CBS applications are defined using YAML configuration files that specify which cells to load and how they connect.

**Configuration Structure:**
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
# Load Flutter web app
cargo run -p body -- --app apps/flutter_flow_web_app.yaml

# Load CLI greeter app  
cargo run -p body -- --app apps/cli_greeter_app.yaml

# Use default configuration
cargo run -p body
```

**Environment Variables:**
```bash
export CBS_APP_CONFIG=apps/flutter_flow_web_app.yaml
cargo run -p body
```

### 15.3 Configuration Validation

* Schema validation for all configuration files
* Cell path and dependency validation
* Circular dependency detection
* Missing cell error reporting
* Configuration hot reloading support (future)

### 15.4 Pre-built Applications

**CLI Greeter App (`apps/cli_greeter_app.yaml`):**
- Traditional CLI application with stdin/stdout interaction
- Demonstrates basic CBS cell communication patterns
- Uses existing Rust cells: prompt_name, logic_greet, print_greeting

**Flutter Flow Web App (`apps/flutter_flow_web_app.yaml`):**
- Modern web application displaying "Flow" text
- Demonstrates Flutter web integration with CBS
- Uses Flutter UI cells and Rust web server cells
- Accessible via web browser at configured port
```

### New Section 16: Web Application Support

```markdown
## 16) Web Application Architecture

### 16.1 Flutter Web Integration

CBS supports Flutter web applications through a bridge architecture that connects Flutter UI cells to the CBS message bus.

**Components:**
* **Flutter Cells**: Dart-based cells that compile to JavaScript for web deployment
* **Web Server Cell**: Rust-based HTTP server that serves Flutter assets and provides API endpoints
* **Message Bridge**: HTTP/WebSocket bridge that translates between web protocols and CBS envelopes
* **Build Integration**: Flutter web compilation integrated into CBS build system

### 16.2 Communication Patterns

**HTTP API Bridge:**
* `POST /api/cbs/request` - Send CBS envelope requests
* `GET /api/cbs/subjects` - List registered subjects
* `WebSocket /ws/cbs` - Real-time bidirectional communication

**Message Flow:**
1. Flutter UI generates user interactions
2. Dart cells create CBS envelopes
3. HTTP/WebSocket bridge forwards to message bus
4. Backend cells process requests
5. Responses flow back through bridge to UI

### 16.3 Development Workflow

**Local Development:**
```bash
# Start CBS with Flutter web app
cargo run -p body -- --app apps/flutter_flow_web_app.yaml

# Access application
open http://localhost:8080
```

**Hot Reload:**
* Flutter hot reload for UI changes
* CBS cell hot reload for backend changes (future)
* Configuration hot reload for application switching (future)

### 16.4 Production Deployment

* Single CBS body serves both web assets and API
* Static asset optimization and caching
* WebSocket connection management
* Error handling and graceful degradation
```
```

## Implementation Priority

### Phase 1: Basic Configuration System
1. Implement YAML configuration parsing in body crate
2. Add command line argument support for configuration files
3. Modify cell loading to use configuration instead of hardcoded imports
4. Create example configurations for existing CLI greeter app

### Phase 2: Flutter Web Foundation
1. Create Flutter cell framework with CBS integration
2. Implement HTTP/WebSocket bridge for message bus communication
3. Add web server cell for serving Flutter assets
4. Create basic Flutter Flow UI cell

### Phase 3: Complete Integration
1. Build complete Flutter Flow web application
2. Implement configuration validation and error handling
3. Add hot reloading capabilities
4. Create comprehensive documentation and examples

## Backward Compatibility

All changes maintain backward compatibility with existing CBS functionality:
- Existing cells continue to work without modification
- Default behavior preserved when no configuration specified
- CLI greeter demo continues to work as before
- All existing tests pass without changes

The configuration system is additive and does not break existing functionality while enabling powerful new application composition capabilities.
