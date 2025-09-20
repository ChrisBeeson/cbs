# Cell Body System (CBS) — Master Spec (Body + Body Bus + Cells)

## 0) Goals & Non-Goals

**Goals**

* Ultra-modular architecture: **cells** perform **one task only**.
* **Body** orchestrates; owns the **Body Bus** (message bus).
* **Spec-first** design: contracts & tests drive code; code is replaceable/regenerated.
* **Polyglot-ready** (Rust now; Python/Dart adapters next).
* "Simple core, extensible edges"—small MVP with clean seams.

**Non-Goals (MVP)**

* No dynamic plugin loading/hot reload from disk (manual registration for MVP).
* No complex ACLs in MVP (NATS auth sufficient initially).
* No custom DLQ implementation (leverage NATS JetStream for persistence).

---

## 1) High-Level Architecture

* **Body (binary crate)**: creates **NATS connection**; loads cells; orchestrates flows; exposes control APIs.
* **Body Bus (lib crate)**: NATS-based message router with subject-based routing. Contract-driven, typed envelope.
* **Cells (lib crates)**: single responsibility; subscribe to NATS subjects; publish responses.
* **Organs**: logical namespaces (e.g., `io.*`, `logic.*`) mapped to NATS subject hierarchies.

**NATS Benefits**:
* **Distributed**: cells can run on different machines/containers
* **Resilient**: automatic reconnection, clustering, failover
* **Scalable**: horizontal scaling, load balancing via queue groups
* **Observable**: built-in monitoring, tracing, metrics

**MVP Demo** (Rust CLI): 3 cells

1. `io.prompt_name`: read name from stdin → `Name`.
2. `logic.greet`: `Name` → `Greeting`.
3. `io.print_greeting`: `Greeting` → stdout.

---

## 2) Core Contracts (Stable)

### 2.1 Envelope (message contract)

```json
{
  "id": "uuid",
  "service": "Greeter",
  "verb": "SayHello",
  "schema": "demo/v1/Name",
  "payload": { "name": "Ada" }
}
```

* `service` = capability; `verb` = action.
* `schema` = reference for payload type/version.
* For MVP we validate structurally in tests; bus remains schema-agnostic (simple, fast).

### 2.2 NATS Subject Pattern

* **Request**: `cbs.{service}.{verb}` (e.g., `cbs.greeter.say_hello`)
* **Response**: `cbs.{service}.{verb}.reply.{request_id}`
* **Queue Groups**: `{service}` (enables load balancing across cell instances)

### 2.3 Rust Traits (shared)

* `BodyBus`: `request(envelope) -> Result<Value, BusError>`, `subscribe(subject, handler)`.
* `Cell`: `id()`, `subjects() -> Vec<String>`, `register(&dyn BodyBus)`.

---

## 3) Language Strategy

* **Phase 1 (MVP)**: Rust only (Body, Bus, Cells).
* **Phase 2**: Add **Python** pool (embed CPython via `pyo3`), **Dart** isolates (sidecar). Contracts unchanged.
* **SDKs** later: `cbs_bus_rs`, `cbs_bus_py`, `cbs_bus_dart` mirroring bus API.

**Polyglot Integration Approach**: In Phase 2, the Body will support cells in multiple languages by maintaining the same NATS-based communication contracts (envelope format and subject patterns) across all languages. The integration strategy includes:
- **Language-Specific Pools**: Each language will have a dedicated runtime pool managed by the Body. For Python, this involves embedding CPython using `pyo3` to run scripts within the Rust Body process. For Dart, isolates will run as sidecar processes communicating via NATS or local IPC to the Body.
- **Unified Registration**: Cells, regardless of language, will register with the Body Bus using language-specific SDKs that abstract NATS interactions. The Body will treat all cells uniformly, unaware of their implementation language, focusing only on their subscribed subjects and queue groups.
- **Payload Consistency**: JSON-based payloads in envelopes ensure data interoperability across languages, with SDKs handling serialization/deserialization to native types (e.g., Rust structs, Python dicts, Dart maps).
- **Performance Isolation**: Language pools will be isolated to prevent one language's runtime issues (e.g., Python GIL contention) from affecting others. NATS queue groups will balance load within each language pool.
- **Development Path**: Start with a small set of Python and Dart cells for non-critical tasks, using the MVP Rust cells as a reference for contract compliance. Gradually expand as SDKs mature.
This approach ensures the core architecture remains language-agnostic at the bus level, allowing seamless addition of new language support without altering existing cells or the Body's orchestration logic.

---

## 4) Repository Layout (Workspace)

```
cbs/
├─ Cargo.toml                 # workspace
├─ body/                      # binary: Body (main framework)
│  ├─ src/main.rs
│  └─ tests/integration.rs
├─ body_core/                 # contracts/interfaces shared
│  └─ src/lib.rs
├─ body_bus/                  # in-proc message bus
│  └─ src/lib.rs
└─ cells/
   └─ examples/
      ├─ greeter_rs/          # minimal single cell example
      │  ├─ src/lib.rs
      │  └─ tests/greeter_tests.rs
      ├─ io_prompt_name_rs/
      │  ├─ src/lib.rs
      │  └─ tests/prompt_tests.rs
      ├─ logic_greet_rs/
      │  ├─ src/lib.rs
      │  └─ tests/greet_tests.rs
      └─ io_print_greeting_rs/
         ├─ src/lib.rs
         └─ tests/print_tests.rs
```

---

## 5) Crate Contracts & Dependencies

### 5.1 `body_core` (lib)

* **Purpose**: shared types & traits (Envelope, BusError, BodyBus, Cell).
* **Deps**: `serde`, `serde_json`, `async-trait`, `thiserror`.
* **Tests**: compile-time trait conformance; JSON (de)serialize round-trip for `Envelope`.

### 5.2 `body_bus` (lib)

* **Purpose**: NATS-based message bus with request/reply pattern.
* **Deps**: `async-nats`, `tokio`, `serde`, `serde_json`, `thiserror`, `body_core`, `uuid`.
* **Behavior**:

  * Connects to NATS server (configurable URL, defaults to `nats://localhost:4222`).
  * `request` publishes to subject, waits for reply with timeout.
  * `subscribe` registers handler for subject pattern with queue group.
  * Auto-reconnection and error handling via NATS client.
* **Tests**:

  * Requires NATS server (use `nats-server` in CI or embedded test server).
  * Publishes message, subscribes to subject, asserts response.
  * Timeout handling: request with no subscribers returns `Timeout`.
  * Concurrency: multiple subscribers in same queue group (load balancing).
  * Error propagation: handler errors published as error responses.

### 5.3 Cells (lib)

* **Purpose**: single capability each; register handler(s).
* **Tests** (per cell):

  * Unit tests: pure logic (formatting, IO stubs).
  * NATS integration tests: subscribe to subjects; publish test messages; assert responses.

### 5.4 `body` (bin)

* **Purpose**: main framework. Connects to NATS, registers cells, orchestrates MVP flow.
* **Config**: NATS URL via env var `NATS_URL` or CLI arg `--nats-url`.
* **Integration Test**: requires NATS server; orchestrate end-to-end flow via NATS subjects.

---

## 6) Coding Standards

* **Rust edition**: 2021.
* `cargo fmt` (rustfmt) + `cargo clippy -D warnings`.
* No panics in library code; bubble errors.
* One public handler per **verb**; keep handlers tiny.
* Namespacing by folders (`io.*`, `logic.*`) to hint organs.

---

## 7) Testing Strategy (Everywhere)

**Levels**

1. **Unit**: pure functions inside each cell (no bus).
2. **Component**: cell + bus (register, request, assert).
3. **Integration**: body orchestrates 3 cells; end-to-end success & failure.

**What to test**

* Success paths, invalid/missing inputs, error messages.
* Concurrency: two simultaneous `Greeter.SayHello` calls.
* Stability: envelope round-trip (serde) is lossless.

**CI** (GitHub Actions)

* **Services**: NATS server container for integration tests.
* **Steps**: checkout → toolchain → start NATS → `fmt` (check) → `clippy` (deny warnings) → `build` (release) → `test` (workspace).

**Local Testing Note**: For running integration and component tests locally, ensure a NATS server is active on `localhost:4222` (or your configured `NATS_URL`). Refer to Section 13 for setup instructions using Docker, direct installation, or Homebrew. Tests will fail if NATS is not accessible, so start the server before running `cargo test --workspace`.

**Cell Independence Test Scenario**: To validate that cells can be added or removed without impacting others, an extended integration test should be developed post-MVP. This scenario will involve a setup with at least 6 cells, split across two distinct flows (e.g., a greeting flow and a separate data processing flow with cells like `io.input_data`, `logic.process_data`, and `io.output_result`). The test will:
- Register all cells and verify both flows work end-to-end.
- Remove a cell from one flow (e.g., `logic.greet`) and confirm the other flow (data processing) remains operational.
- Add a new cell (e.g., `logic.format_data`) to the second flow and verify it integrates without changes to existing cells.
This test ensures the architecture supports modularity and independence as new capabilities are added, simulating real-world growth of the system.

---

## 8) Acceptance Criteria (MVP)

* **Prerequisites**: NATS server running on `localhost:4222` (or configured URL).
* `cargo run -p body` prompts for name and prints `Hello <name>!` via NATS messaging.
* All tests pass (`cargo test --workspace`) with NATS server available.
* Lints clean (`fmt`/`clippy` pass).
* Cells communicate **only** via NATS subjects.
* Adding/removing a cell requires **no** changes to others.
* **Distributed ready**: cells can run on separate processes/machines.

---

## 9) File-by-File Requirements (content outline)

> (Agents: generate these files with the content from earlier steps. Where code is omitted below, use the previously provided implementations.)

### 9.1 `/Cargo.toml` (workspace)

* Lists members: `body`, `body_core`, `body_bus`, and all cell crates.
* `resolver = "2"`.

### 9.2 `/body_core/src/lib.rs`

* **Types**: `Envelope`, `BusError`.
* **Traits**: `BodyBus`, `Cell`.
* **Tests**:

  * `serde` round-trip for `Envelope`.
  * `BusError` display messages.

### 9.3 `/body_bus/src/lib.rs`

* **Type**: `NatsBus` with NATS client connection.
* `BodyBus` impl with `subscribe` and `request` methods.
* **Config**: connection URL, timeouts, reconnection settings.
* **Tests**:

  * Connects to NATS, subscribes to subject, publishes request, asserts response.
  * Timeout handling for requests with no subscribers.
  * Queue group load balancing with multiple subscribers.
  * Error propagation and reconnection scenarios.

### 9.4 `/cells/examples/greeter_rs/src/lib.rs`

* Function `register(&dyn BodyBus)` that subscribes to `cbs.greeter.say_hello` with queue group `greeter`.
* **Unit test** (`tests/greeter_tests.rs`):

  * Pure handler logic with sample envelope.
  * NATS integration test: subscribe, publish request, assert response.

### 9.5 `/cells/io_prompt_name_rs/src/lib.rs`

* Subscribes to `cbs.prompt_name.read` with queue group `prompt_name`.
* **Unit test**: fake stdin (wrap in trait or function to inject input); assert output JSON.
* **NATS test**: subscribe, publish request, assert response with name.

### 9.6 `/cells/logic_greet_rs/src/lib.rs`

* Subscribes to `cbs.greeter.say_hello` with queue group `greeter`.
* **Unit test**: formatting logic.
* **NATS test**: subscribe, publish name, assert greeting response.

### 9.7 `/cells/io_print_greeting_rs/src/lib.rs`

* Subscribes to `cbs.printer.write` with queue group `printer`.
* **Unit test**: capture stdout; assert output.
* **NATS test**: subscribe, publish message, assert stdout and response.

### 9.8 `/body/src/main.rs`

* Connects to NATS server (configurable URL).
* Creates `NatsBus` and registers the 3 cells.
* Orchestrates: `cbs.prompt_name.read` → `cbs.greeter.say_hello` → `cbs.printer.write`.
* **Integration test** (`body/tests/integration.rs`):

  * Requires NATS server; tests full flow via NATS messaging.

### 9.9 `/README.md`

* Purpose, run instructions, structure, next steps.

### 9.10 `/.github/workflows/rust.yml`

* **Services**: NATS server container (`nats:latest`).
* Single stable job: start NATS → fmt/clippy/build/test.
* **Environment**: `NATS_URL=nats://nats:4222` for tests.

---

## 10) Example Test Snippets (ready for agents)

### 10.1 `body_core` envelope round-trip

```rust
#[test]
fn envelope_roundtrip() {
    let env = Envelope {
        id: "1".into(),
        service: "Greeter".into(),
        verb: "SayHello".into(),
        schema: "demo/v1/Name".into(),
        payload: serde_json::json!({"name":"Ada"}),
    };
    let s = serde_json::to_string(&env).unwrap();
    let back: Envelope = serde_json::from_str(&s).unwrap();
    assert_eq!(back.service, "Greeter");
    assert_eq!(back.verb, "SayHello");
    assert_eq!(back.payload["name"], "Ada");
}
```

### 10.2 `body_bus` NATS timeout

```rust
#[tokio::test]
async fn request_timeout_no_subscribers() {
    let bus = NatsBus::connect("nats://localhost:4222").await.unwrap();
    let err = bus.request(Envelope {
        id:"1".into(), service:"non_existent".into(), verb:"action".into(),
        schema:"demo/v1/Void".into(), payload:serde_json::json!({})
    }).await.unwrap_err();
    match err { BusError::Timeout => {}, _ => panic!("Expected timeout") }
}
```

### 10.3 `logic_greet_rs` unit test

```rust
#[test]
fn formats_hello() {
    let name = "Grace";
    let msg = format!("Hello {}!", name);
    assert_eq!(msg, "Hello Grace!");
}
```

### 10.4 `io_print_greeting_rs` stdout capture

```rust
#[test]
fn prints_message() {
    use std::io::{self, Write};
    let mut buf = Vec::new();
    writeln!(&mut buf, "Hello Ada!").unwrap();
    assert_eq!(String::from_utf8(buf).unwrap(), "Hello Ada!\n");
}
```

### 10.5 Integration (body/tests/integration.rs)

```rust
#[tokio::test]
async fn full_flow_via_nats() {
    use body_bus::NatsBus;
    use body_core::{BodyBus as _, Envelope};
    
    let bus = NatsBus::connect("nats://localhost:4222").await.unwrap();
    cells_examples_greeter_rs::register(&bus).await.unwrap();
    
    // Test via NATS pub/sub:
    let out = bus.request(Envelope{
        id:"1".into(), service:"greeter".into(), verb:"say_hello".into(),
        schema:"demo/v1/Name".into(), payload:serde_json::json!({"name":"Test"})
    }).await.unwrap();
    assert_eq!(out["message"], "Hello Test!");
}
```

---

## 11) Extensibility Hooks (next phases)

* **JetStream**: persistent messaging, replay, deduplication via NATS JetStream.
* **Spec loader**: YAML Body Spec defines cells; Body reads and registers.
* **Policies**: leverage NATS headers for timeout/retry; circuit breakers.
* **Observability**: NATS built-in monitoring + `tracing` spans; export OTLP.
* **Language pools**: NATS language clients (Python, Dart, Go, etc.) with same subjects.
* **Security**: NATS authentication, TLS, signed JWTs; decentralized auth.
* **Clustering**: NATS clustering, leaf nodes, superclusters for global scale.

**Basic Documentation and Interface Sketches**:

- **JetStream Integration**:
  - **Purpose**: Enable persistent messaging for reliable delivery and replay of events.
  - **Interface Sketch**: Extend `BodyBus` trait with `create_stream(stream_name: &str, subjects: Vec<&str>) -> Result<Stream, BusError>` and `publish_to_stream(subject: &str, envelope: Envelope) -> Result<(), BusError>` to manage streams and publish persistent messages. Cells can opt-in to JetStream subscriptions via a configuration flag in `Cell::register()`.
  - **Next Step**: Implement in `body_bus` crate post-MVP, targeting NATS JetStream APIs for durability.

- **Spec Loader**:
  - **Purpose**: Allow dynamic definition of cells and flows via a YAML spec file.
  - **Interface Sketch**: Define a `BodySpec` struct with fields like `cells: Vec<CellSpec>` where `CellSpec` includes `id: String`, `subjects: Vec<String>`, and `language: String`. Add `Body::load_spec(path: &str) -> Result<(), SpecError>` to parse and register cells dynamically.
  - **Next Step**: Create a `body_spec` crate for YAML parsing and validation, integrated into `body` binary.

- **Policies (Timeout/Retry/Circuit Breaker)**:
  - **Purpose**: Enhance reliability with configurable message handling policies.
  - **Interface Sketch**: Add a `PolicyConfig` struct to `body_core` with fields like `timeout_ms: u64`, `max_retries: u8`, and `circuit_breaker_threshold: u16`. Extend `BodyBus::request()` to accept an optional `PolicyConfig` parameter for per-request policies.
  - **Next Step**: Implement policy logic in `body_bus`, leveraging NATS headers for metadata.

- **Observability**:
  - **Purpose**: Provide detailed insights into system behavior and performance.
  - **Interface Sketch**: Integrate `tracing` crate into `body_bus` with a `trace_request(envelope: &Envelope, span: Span)` method to log request lifecycles. Add `BodyBus::export_metrics(format: MetricFormat) -> Result<String, BusError>` for OTLP or Prometheus export.
  - **Next Step**: Define observability hooks in `body_core` and implement in `body_bus` with configurable exporters.

- **Language Pools**:
  - **Purpose**: Support cells in multiple languages with isolated runtimes.
  - **Interface Sketch**: Define a `LanguagePool` trait in `body_core` with methods like `register_cell(cell_id: &str, runtime: LanguageRuntime) -> Result<(), PoolError>` and `dispatch(envelope: Envelope) -> Result<Value, BusError>`. Implementations for Rust, Python, and Dart will handle runtime-specific logic.
  - **Next Step**: Develop pool implementations post-MVP, starting with Python via `pyo3` (see Section 3 for approach).

- **Security**:
  - **Purpose**: Secure communications and access in distributed environments.
  - **Interface Sketch**: Extend `NatsBus` configuration in `body_bus` with `SecurityConfig` struct containing `auth: Option<AuthMethod>`, `tls: Option<TlsConfig>`. Add `BodyBus::set_security(config: SecurityConfig) -> Result<(), BusError>` to apply settings at connection time.
  - **Next Step**: Implement basic auth and TLS in MVP follow-up, expanding to JWTs later.

- **Clustering**:
  - **Purpose**: Enable global scale and resilience with NATS clustering.
  - **Interface Sketch**: Add `ClusterConfig` to `body_bus` with fields like `leaf_node_urls: Vec<String>` and `supercluster_id: String`. Extend `NatsBus::connect_with_cluster(url: &str, config: ClusterConfig) -> Result<Self, BusError>` for distributed setups.
  - **Next Step**: Document clustering setup in NATS configuration post-MVP, test with leaf nodes in CI.

These sketches provide placeholders for future implementation, ensuring that extensibility points are considered in the core design. Each hook maintains the contract-driven approach of CBS, allowing incremental adoption without breaking existing functionality.

---

## 12) Done-Definition Checklist (agents must satisfy)

* [ ] **NATS server** running and accessible (local or containerized). See Section 13 for setup instructions using Docker, direct installation, or Homebrew, including troubleshooting tips.
* [ ] Workspace builds & runs with `cargo run -p body` (connects to NATS). Ensure NATS is running as described in Section 13 before execution.
* [ ] All **unit**, **component**, **integration** tests pass via `cargo test --workspace`. Refer to the Local Testing Note in Section 7 for NATS setup requirements for tests.
* [ ] `cargo fmt --all -- --check` passes.
* [ ] `cargo clippy --all-targets --all-features -D warnings` passes.
* [ ] `README.md` explains NATS setup, run instructions, distributed capabilities. Update to reference Section 13 for detailed NATS installation guidance.
* [ ] GitHub Actions workflow green with NATS service container.

---

This spec is intentionally **simple to implement** yet **strongly structured** for growth: clean contracts, tiny bus, tiny cells, lots of tests, and clear seams for polyglot, policies, observability, and networking.

---

## 13) Setting Up NATS Server

To run the Cell Body System (CBS) MVP demo and tests, you need a NATS server running locally or on a configured URL. Here's how to set it up quickly:

### Option 1: Using Docker (Recommended for Development)

If you have Docker installed, this is the easiest way to run a NATS server:

```bash
docker run -d --name nats-server -p 4222:4222 nats:latest
```

This command pulls the latest NATS image and runs a container named `nats-server`, exposing port 4222 (the default NATS port) to your local machine.

To stop the server later:

```bash
docker stop nats-server
```

To remove the container:

```bash
docker rm nats-server
```

### Option 2: Installing NATS Server Locally

If you prefer to install NATS directly on your machine:

1. **Download NATS Server**: Visit the [NATS GitHub releases page](https://github.com/nats-io/nats-server/releases) and download the appropriate binary for your platform (e.g., `nats-server-v2.x.x-darwin-amd64.zip` for macOS).
2. **Extract and Run**: Unzip the file and run the server with:

   ```bash
   ./nats-server
   ```

   By default, it will listen on `localhost:4222`. You can specify a different port or configuration if needed (see NATS documentation).

3. **Verify**: Ensure the server is running by checking the output for a message like `[INF] Listening for client connections on 0.0.0.0:4222`.

### Option 3: Using Homebrew (macOS)

For macOS users with Homebrew installed:

```bash
brew install nats-server
nats-server
```

### Troubleshooting

- **Port Conflict**: If port 4222 is already in use, you can run NATS on a different port by passing the `-p` flag (e.g., `nats-server -p 4223`) and update the `NATS_URL` environment variable or CLI argument accordingly (`--nats-url nats://localhost:4223`).
- **Connection Issues**: Ensure your firewall allows connections on the NATS port, and double-check the URL in your CBS configuration.

### Additional Resources

- **NATS Documentation**: [https://docs.nats.io](https://docs.nats.io) for advanced configuration, clustering, and security options.
- **NATS CLI**: Install the `nats` CLI tool for interacting with the server (`brew install natsio` or download from GitHub) to test connections and publish/subscribe to subjects.

**Basic Security Note for MVP**: While comprehensive security is not a goal for the MVP, be aware that the default NATS setup described here does not include authentication or encryption. For local development, this is acceptable, but if you expose the NATS server beyond your machine (e.g., for distributed cell testing), consider enabling basic security features:
- **Authentication**: Use NATS user/password or token authentication by configuring accounts in the NATS server (see [NATS Security Docs](https://docs.nats.io/running-a-nats-service/configuration/securing_nats)). Update the `NATS_URL` with credentials (e.g., `nats://user:pass@localhost:4222`).
- **TLS**: Enable TLS for encrypted connections if operating over untrusted networks. Instructions are in the NATS documentation.
- **Firewall**: Restrict access to the NATS port (default 4222) to trusted IPs only.
For MVP, the Body and cells do not implement custom security layers, relying on NATS built-in options. Future phases (see Section 11) will expand on security with JWTs and decentralized auth. If deploying outside a secure environment, consult the NATS documentation and adjust configurations before running `cargo run -p body` or tests.

This setup should cover most development scenarios for CBS. If you encounter issues, ensure the NATS server is running before executing `cargo run -p body` or tests.

---

## 14) Clarifications, Data Flows, and Conventions

### 14.1 Data Flows
- Canonical MVP flow and lifecycle are documented in `ai/docs/data_flows.md`.

### 14.2 Naming & Subjects
- Use lowercase snake_case for `service` and `verb` everywhere (envelope and subject).
- Subject derivation: `cbs.{service}.{verb}`; queue group: `{service}`.

### 14.3 Request/Reply Semantics
- Use NATS request API; replies use auto-generated inbox subjects. The response subject pattern in §2.2 is descriptive only; it is not required by clients.

### 14.4 Error Contract
- Cells reply with an error envelope on failure:

```json
{ "id": "uuid", "error": { "code": "BadRequest", "message": "...", "details": {} } }
```

### 14.5 Versioning
- `schema` follows `domain/v{n}/Type`. Bump major on breaking changes; deprecate N-1 gracefully.

### 14.6 Observability
- Treat `Envelope.id` as correlation id. Emit spans/logs tagged with `service`, `verb`, `schema`.

### 14.7 Known Gotchas (for LLMs)
- Don’t mix case styles; don’t handcraft reply subjects; don’t register multiple different handlers for the same subject unless for scaling. See `ai/docs/llm_tripwires.md` for the concise checklist.

### 14.8 Envelope Schema
- Canonical JSON Schema: `ai/docs/schemas/envelope.schema.json`. Validate envelopes against this for tooling.

### 14.9 Error Codes
- MVP error codes are defined in `ai/docs/error_codes.md`. Use `code`, `message`, optional `details`.

### 14.10 Error Verbosity Guidance
- Cells may return verbose custom fields within `error` (e.g., `hint`, `path`, `cell_trace`