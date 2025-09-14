# Technical Stack

## Core Framework

- **application_framework**: Rust 2021 Edition with Cargo workspace
- **message_bus**: NATS (nats://localhost:4222) with JetStream for persistence
- **database_system**: Supabase PostgreSQL with MCP integration
- **container_runtime**: Docker with multi-stage builds

## Language Support

- **primary_language**: Rust (Body, Bus, Core contracts)
- **polyglot_support**: Python (via pyo3 embedding), Dart (sidecar processes)
- **runtime_isolation**: Language-specific pools with NATS communication

## Development Tools

- **code_formatting**: rustfmt, Black (Python), dart format
- **linting**: clippy, Ruff (Python), dart analyze  
- **testing_framework**: Rust built-in tests, PyTest, Flutter test
- **schema_validation**: JSON Schema with ajv validation

## Communication & Messaging

- **message_protocol**: NATS request/reply with typed JSON envelopes
- **subject_pattern**: `cbs.{service}.{verb}` with queue groups
- **serialization**: serde_json (Rust), native JSON (Python/Dart)
- **correlation_tracking**: UUID v4 envelope IDs for distributed tracing

## Infrastructure & Deployment

- **application_hosting**: Docker containers with NATS clustering
- **database_hosting**: Supabase cloud with connection pooling
- **message_hosting**: NATS server (local dev) / NATS cloud (production)
- **deployment_solution**: Docker Compose (dev), Kubernetes (production)

## Observability & Monitoring

- **logging**: log crate (Rust), structured logging with correlation IDs
- **tracing**: Built-in span tracking across cell communications
- **metrics**: NATS built-in monitoring with custom cell metrics
- **error_handling**: Typed error envelopes with structured details

## Development Workflow

- **code_repository_url**: Git with conventional commits
- **ci_cd**: GitHub Actions with NATS service containers
- **pre_commit_hooks**: Format, lint, and schema validation
- **testing_strategy**: Unit, component, and integration tests with NATS

## Security & Configuration

- **authentication**: NATS user/password (dev), JWT tokens (production)
- **encryption**: TLS for NATS connections in production
- **configuration**: Environment variables with sane defaults
- **secrets_management**: Supabase vault integration

## Cell-Specific Technologies

### Rust Cells
- **async_runtime**: tokio with async-trait for cell interfaces
- **dependencies**: serde, serde_json, async-nats, thiserror, uuid

### Python Cells  
- **runtime**: CPython 3.11+ embedded via pyo3
- **dependencies**: asyncio, aiohttp, pydantic for validation
- **package_management**: pip with requirements.txt

### Dart Cells
- **runtime**: Dart isolates as sidecar processes
- **dependencies**: dart:io, dart:convert for JSON handling
- **package_management**: pub with pubspec.yaml
