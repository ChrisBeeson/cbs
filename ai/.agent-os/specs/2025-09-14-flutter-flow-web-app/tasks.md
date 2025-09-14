# Spec Tasks

## Tasks

- [x] 1. **Set up Flutter Flow Web Application Structure**
  - [x] 1.1 Write tests for application loading system
  - [x] 1.2 Create `applications/flutter_flow_web/` directory structure
  - [x] 1.3 Implement app.yaml configuration format and validation
  - [x] 1.4 Update body/main.rs to accept `--app` parameter and load Flutter Flow web app
  - [x] 1.5 Create Flutter web application workspace with pubspec.yaml
  - [x] 1.6 Set up basic web/ directory with index.html template
  - [x] 1.7 Verify all tests pass for application loading

- [x] 2. **Create Direct NATS Dart SDK**
  - [x] 2.1 Write tests for Dart CBS integration with direct NATS
  - [x] 2.2 Create `shared_cells/dart/cbs_sdk/` with Cell trait implementation
  - [x] 2.3 Implement direct NATS client connection for CBS envelope communication
  - [x] 2.4 Add JSON serialization/deserialization for CBS envelopes in Dart
  - [x] 2.5 Create error propagation and timeout handling
  - [x] 2.6 Implement pubspec.yaml with NATS client dependency (dart_nats)
  - [x] 2.7 Verify all tests pass for direct NATS Dart SDK

- [x] 3. **Build Flutter Flow Web Application**
  - [x] 3.1 Write tests for Flutter UI rendering cell
  - [x] 3.2 Create `applications/flutter_flow_web/` directory structure with web/, cells/ subdirectories
  - [x] 3.3 Implement `cells/flow_ui/` Dart cell that renders "Flow" centered with modern styling
  - [x] 3.4 Create responsive, cross-browser compatible CSS/styling
  - [x] 3.5 Set up Flutter web compilation and build configuration
  - [x] 3.6 Create index.html template for Flutter web deployment
  - [x] 3.7 Verify all tests pass for Flutter web app

- [x] 4. **Implement Static Web Server** 
  - [x] 4.1 Write tests for static file serving
  - [x] 4.2 Create `shared_cells/rust/web_server/` with HTTP server implementation
  - [x] 4.3 Implement static file serving for Flutter web build output
  - [x] 4.4 Add CORS support for development
  - [x] 4.5 Create simple health check endpoint
  - [x] 4.6 Verify all tests pass for web server

- [x] 5. **Integrate Build System and Deployment**
  - [x] 5.1 Write tests for build integration and Flutter web deployment
  - [x] 5.2 Configure Flutter web build to output to `applications/flutter_flow_web/web/`
  - [x] 5.3 Set up unified build system that compiles both Rust and Flutter components
  - [x] 5.4 Create development workflow with NATS server startup
  - [x] 5.5 Create production build configuration with optimized assets
  - [x] 5.6 Test Flutter Flow web app: `cargo run -p body -- --app applications/flutter_flow_web`
  - [x] 5.7 Verify all tests pass and deployment works end-to-end
