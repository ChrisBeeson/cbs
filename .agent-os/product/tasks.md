# Spec Tasks

## Tasks

- [x] 1. Core Contracts and Types Implementation
  - [x] 1.1 Write tests for Envelope serialization/deserialization with JSON Schema validation
  - [x] 1.2 Write tests for BusError display messages and error propagation
  - [x] 1.3 Write tests for BodyBus and Cell trait conformance
  - [x] 1.4 Implement body_core crate with Envelope, BusError, BodyBus, and Cell traits
  - [x] 1.5 Create Cargo.toml workspace with proper dependencies (serde, async-trait, thiserror)
  - [x] 1.6 Verify all core contract tests pass

- [ ] 2. NATS Message Bus Implementation
  - [ ] 2.1 Write tests for NATS connection and reconnection scenarios
  - [ ] 2.2 Write tests for request/reply pattern with timeout handling
  - [ ] 2.3 Write tests for queue group load balancing with multiple subscribers
  - [ ] 2.4 Write tests for error propagation and envelope validation
  - [ ] 2.5 Implement NatsBus struct with async-nats client integration
  - [ ] 2.6 Implement BodyBus trait with subscribe and request methods
  - [ ] 2.7 Add NATS configuration (URL, timeouts, reconnection settings)
  - [ ] 2.8 Verify all message bus tests pass

- [ ] 3. Example Cells Implementation
  - [ ] 3.1 Write unit tests for io.prompt_name cell with stdin mocking
  - [ ] 3.2 Write NATS integration tests for prompt_name cell registration and response
  - [ ] 3.3 Write unit tests for logic.greet cell formatting logic
  - [ ] 3.4 Write NATS integration tests for greeter cell with name input/greeting output
  - [ ] 3.5 Write unit tests for io.print_greeting cell with stdout capture
  - [ ] 3.6 Write NATS integration tests for printer cell message handling
  - [ ] 3.7 Implement all three cells with proper subject subscriptions and queue groups
  - [ ] 3.8 Verify all cell tests pass independently

- [ ] 4. Body Framework and Orchestration
  - [ ] 4.1 Write integration tests for full end-to-end flow via NATS messaging
  - [ ] 4.2 Write tests for cell registration and NATS connection management
  - [ ] 4.3 Write tests for error handling and graceful shutdown
  - [ ] 4.4 Write tests for configuration via environment variables and CLI args
  - [ ] 4.5 Implement Body binary that connects to NATS and registers cells
  - [ ] 4.6 Implement orchestration flow: prompt_name → greeter → printer
  - [ ] 4.7 Add configuration support for NATS_URL and connection parameters
  - [ ] 4.8 Verify all integration tests pass with NATS server

- [ ] 5. CI/CD and Documentation
  - [ ] 5.1 Write GitHub Actions workflow with NATS service container
  - [ ] 5.2 Configure pre-commit hooks for rustfmt and clippy validation
  - [ ] 5.3 Set up cargo workspace with proper linting and formatting rules
  - [ ] 5.4 Create comprehensive README with NATS setup instructions
  - [ ] 5.5 Document envelope validation script and schema compliance
  - [ ] 5.6 Add troubleshooting guide for common NATS connection issues
  - [ ] 5.7 Verify CI pipeline passes with all checks (fmt, clippy, tests)
  - [ ] 5.8 Verify documentation completeness and accuracy
