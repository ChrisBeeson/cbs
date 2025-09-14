# Spec Tasks

## Tasks

- [ ] 1. **Set up Flutter Flow Web Application Structure**
  - [ ] 1.1 Write tests for application loading system
  - [ ] 1.2 Create `applications/flutter_flow_web/` directory structure
  - [ ] 1.3 Implement app.yaml configuration format and validation
  - [ ] 1.4 Update body/main.rs to accept `--app` parameter and load Flutter Flow web app
  - [ ] 1.5 Create Flutter web application workspace with pubspec.yaml
  - [ ] 1.6 Set up basic web/ directory with index.html template
  - [ ] 1.7 Verify all tests pass for application loading

- [ ] 2. **Create Direct NATS Dart SDK**
  - [ ] 2.1 Write tests for Dart CBS integration with direct NATS
  - [ ] 2.2 Create `shared_cells/dart/cbs_sdk/` with Cell trait implementation
  - [ ] 2.3 Implement direct NATS client connection for CBS envelope communication
  - [ ] 2.4 Add JSON serialization/deserialization for CBS envelopes in Dart
  - [ ] 2.5 Create error propagation and timeout handling
  - [ ] 2.6 Implement pubspec.yaml with NATS client dependency (dart_nats)
  - [ ] 2.7 Verify all tests pass for direct NATS Dart SDK

- [ ] 3. **Build Flutter Flow Web Application**
  - [ ] 3.1 Write tests for Flutter UI rendering cell
  - [ ] 3.2 Create `applications/flutter_flow_web/` directory structure with web/, cells/ subdirectories
  - [ ] 3.3 Implement `cells/flow_ui/` Dart cell that renders "Flow" centered with modern styling
  - [ ] 3.4 Create responsive, cross-browser compatible CSS/styling
  - [ ] 3.5 Set up Flutter web compilation and build configuration
  - [ ] 3.6 Create index.html template for Flutter web deployment
  - [ ] 3.7 Verify all tests pass for Flutter web app

- [ ] 4. **Implement Static Web Server** 
  - [ ] 4.1 Write tests for static file serving
  - [ ] 4.2 Create `shared_cells/rust/web_server/` with HTTP server implementation
  - [ ] 4.3 Implement static file serving for Flutter web build output
  - [ ] 4.4 Add CORS support for development
  - [ ] 4.5 Create simple health check endpoint
  - [ ] 4.6 Verify all tests pass for web server

- [ ] 5. **Integrate Build System and Deployment**
  - [ ] 5.1 Write tests for build integration and Flutter web deployment
  - [ ] 5.2 Configure Flutter web build to output to `applications/flutter_flow_web/web/`
  - [ ] 5.3 Set up unified build system that compiles both Rust and Flutter components
  - [ ] 5.4 Create development workflow with NATS server startup
  - [ ] 5.5 Create production build configuration with optimized assets
  - [ ] 5.6 Test Flutter Flow web app: `cargo run -p body -- --app applications/flutter_flow_web`
  - [ ] 5.7 Verify all tests pass and deployment works end-to-end
