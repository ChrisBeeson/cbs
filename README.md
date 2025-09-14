# Cell Body System (CBS) — MVP

The **Cell Body System (CBS)** is a modular microservice framework that helps developers build scalable, maintainable distributed systems by providing a biological-inspired architecture with ultra-modular cells, message-driven communication, and polyglot runtime support.

At its heart:

* **Cells**: the smallest unit of work. Each does *one task and one task well*.
* **Body**: orchestrates cells and owns the **Body Bus** (message bus).
* **Envelopes**: typed messages that carry requests and responses.
* **Specs**: every cell has a spec (its “DNA”), making behaviour testable, reproducible, and replaceable.

The MVP demonstrates this concept with simple Rust cells connected via the Body Bus, with optional NATS support for scaling out.

---

## Quick Start

### 1. Run NATS (optional, for distributed mode)

```bash
docker run -d --name nats-server -p 4222:4222 nats:latest
```

### 2. Run demo

```bash
cargo run -p body
```

### 3. Run tests

```bash
cargo test --workspace
```

---

## What You’ll See

The MVP demo wires three simple Rust cells:

1. **PromptName** — reads a name from stdin.
2. **Greeter** — takes a `Name` and produces a `Greeting`.
3. **Printer** — prints the greeting to stdout.

Example run:

```
$ cargo run -p body
Enter your name: Ada
Hello Ada!
```

---

## Documentation

* **Master Spec** → [`ai/master_build_specs.md`](ai/master_build_specs.md) (see §13 for NATS setup)
* **Data Flows** → [`ai/docs/data_flows.md`](ai/docs/data_flows.md)
* **LLM Tripwires** → [`ai/docs/llm_tripwires.md`](ai/docs/llm_tripwires.md)
* **Envelope Schema** → [`ai/docs/schemas/envelope.schema.json`](ai/docs/schemas/envelope.schema.json)
* **Error Codes** → [`ai/docs/error_codes.md`](ai/docs/error_codes.md)

---

## Envelope Validation

Validate envelopes against the schema:

```bash
./ai/scripts/validate_envelopes.sh
```

---

## Roadmap

* **MVP (current)**: Rust cells + in-proc bus; tests for all cells and bus.
* **Phase 2**: Add polyglot support (Python/Dart), shared runtime pools.
* **Phase 3**: Swap in **NATS** for distributed messaging.
* **Phase 4**: Enforce schemas, add retries, deadlines, and observability.
* **Phase 5**: Self-healing orchestration, scaling, and monitoring.

---

## Principles

* **Spec is truth** — behaviour defined by machine-readable specs.
* **Isolation** — cells talk *only* via the bus.
* **Polyglot** — designed for Rust, Python, Dart (others via adapters).
* **Simple core** — start small, scale gracefully.

