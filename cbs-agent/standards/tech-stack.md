# Tech Stack

## Cell Body System (CBS) Architecture

**Core Framework**: Modular cell-based microservice architecture inspired by biological systems

## Languages & Runtimes

- **Primary Language**: Rust 2021 Edition
- **Mobile/Web UI**: Dart/Flutter SDK >=3.0.0 <4.0.0
- **Polyglot Support**: Python >=3.11 (via cells)
- **Build System**: Cargo workspace (Rust), Flutter build (Dart)
- **Package Managers**: Cargo, pub (Dart), pip (Python)

## Core Infrastructure

- **Message Bus**: NATS with JetStream persistence
- **Database**: Supabase PostgreSQL with MCP integration
- **Communication Protocol**: NATS request/reply with typed JSON envelopes
- **Subject Pattern**: `cbs.{service}.{verb}` with queue groups
- **Container Runtime**: Docker with multi-stage builds

## Frontend Technologies

- **UI Framework**: Flutter for Web
- **State Management**: Riverpod
- **HTTP Client**: http ^1.1.0
- **WebSocket**: web_socket_channel ^2.4.0
- **Material Design**: Flutter's built-in Material Design

## Development Tools

- **Code Formatting**: rustfmt, dart format, Black (Python)
- **Linting**: clippy, flutter_lints ^3.0.0, Ruff (Python)
- **Testing**: Rust built-in tests, flutter_test, mockito ^5.4.2
- **Build Tools**: build_runner ^2.4.7, build_web_compilers ^4.0.0
- **Schema Validation**: JSON Schema with ajv validation

## Key Dependencies

### Rust
- serde/serde_json (serialization)
- async-trait, futures-util (async)
- async-nats ^0.20 (message bus)
- tokio (async runtime)
- uuid v4 (correlation IDs)
- thiserror (error handling)

### Dart/Flutter
- CBS SDK (custom cell framework)
- HTTP & WebSocket clients
- Material Design components

## Deployment & Infrastructure

- **Development**: Docker Compose with NATS server
- **Production**: Kubernetes with NATS clustering
- **Database Hosting**: Supabase cloud with connection pooling
- **CI/CD**: GitHub Actions with NATS service containers

## Observability

- **Logging**: log.d(), log.e(), log.i(), log.w() (custom logger)
- **Tracing**: UUID correlation IDs across cell communications
- **Error Handling**: Typed error envelopes with structured details
- **Monitoring**: NATS built-in monitoring + custom cell metrics
