# Technical Specification

Technical spec for `@.agent-os/specs/2025-09-14-flutter-flow-web-app/spec.md`.

## Technical Requirements

### Flutter Web Cell Framework
- **CBS Dart SDK**: `cbs_bus_dart` mirroring Rust `body_core` traits
- **Cell Trait**: `id()`, `subjects()`, `register()` in Dart
- **Bus Integration**: WebSocket/HTTP bridge to CBS
- **Web Compilation**: Flutter web build artifacts configured

### Self-Contained Application System
- **App Directory**: `applications/{app_name}/` isolated
- **Configuration**: `app.yaml` lists cells, deps, config
- **Cell Registry**: Dynamic load from app dirs
- **Shared Cells**: Reference from `shared_cells/`

### Web UI Architecture
- **Responsive**: Center "Flow" with responsive typography
- **Modern Styling**: Clean, minimal
- **Performance**: Small bundle, fast load
- **Compatibility**: Chrome, Firefox, Safari, Edge

### CBS Integration Points
- **Bridge**: Translate Dart ↔ CBS envelopes
- **Serialization**: JSON encode/decode for envelopes in Dart
- **Errors**: Propagate errors between UI and backend
- **State**: Prefer CBS message patterns over local state

### Build System Integration
- **Unified Build**: Integrate Flutter web build in workspace
- **Assets**: Serve static assets correctly
- **Dev Server**: Local server with hot reload
- **Production**: Optimized builds, minified assets

### Application Loading Mechanism
- **Discovery**: Find apps in `applications/`
- **Loader**: Parse `app.yaml`, validate structure
- **Registration**: Load app and shared cells
- **Paths**: Resolve relative paths
- **Validation**: Schema and dependency checks

## External Dependencies

### Flutter Web
- **flutter**: ^3.0.0

### CBS Dart SDK
- **http**: ^0.13.0
- **web_socket_channel**: ^2.0.0

### Configuration
- **yaml**: ^3.1.0 (Dart)
- **serde_yaml**: ^0.9.0 (Rust)

### Development
- **build_web_compilers**: ^3.0.0
