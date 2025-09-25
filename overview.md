### Cell Body System (CBS) Overview

CBS is a pragmatic alternative to spec‑driven, monolithic design. Instead of one intertwined system that is hard to refine, CBS decomposes software into independent, reusable cells that only communicate over a message bus. Refinement becomes a local change, not a risky rewrite.

---

### Why spec‑driven monoliths hurt refinement

- **Intertwined concerns**: UI, logic, storage, and integrations get entangled. A small change ripples everywhere.
- **Refactor fear**: Specs describe big systems; implementations accrete cross‑cutting dependencies. Changing one part risks regressions.
- **Slow feedback**: End‑to‑end context is required to test anything meaningful.
- **Hidden coupling**: Direct calls leak assumptions (data shapes, timing, side effects) across layers.
- **Difficult parallelism**: Teams block on each other inside the same code paths.

The result: specs grow, code hardens, refinement slows.

---

### The cellular alternative

Break the system into cells, each with one responsibility, communicating only via typed messages on the bus.

- **Separation of concerns**
  - UI cells: presentation only
  - Logic cells: rules and decisions
  - Storage cells: persistence and caching
  - Integration cells: external APIs and services
  - IO cells: file/network/stdio boundaries

- **Bus‑only communication**
  - Subjects: `cbs.<service>.<verb>` (snake_case)
  - Typed envelopes with schema versioning (`service.verb.v1`)
  - No direct cell‑to‑cell calls, ever

- **Spec‑first, per cell**
  - Each cell ships with `ai/spec.md` defining contracts
  - Tests validate both logic and bus handling

- **Composable and replaceable**
  - Cells can be evolved, swapped, or multiplied horizontally without breaking others

---

### Minimal anatomy

```text
applications/<app>/cells/<cell>/
  ai/spec.md          # Interface and behavior
  lib/                # Implementation
  test/               # Tests
  pubspec.yaml        # (Dart) or Cargo.toml (Rust)
```

---

### Message contracts (technical)

- **Subject format**: `cbs.<service>.<verb>`
- **Envelope**: JSON with `schema`, `payload`, `correlation_id`
- **Versioning**: increment `schema` to evolve without breaking

```json
{
  "schema": "auth.login.v2",
  "correlation_id": "a3b2-…",
  "payload": {
    "email": "user@example.com",
    "otp": "123456"
  }
}
```

---

### How CBS makes refinement easy

1. Update the target cell’s `ai/spec.md` (new schema version if needed).
2. Adjust tests for that cell; run them in isolation.
3. Implement the smallest change inside the cell’s boundary.
4. Publish the new message version; keep old versions until consumers migrate.
5. Other cells continue to work; migrate on their own timeline.

Refinement is local, reversible, testable, and incremental.

---

### Key features

- **Bus‑only isolation**: Strict separation via typed envelopes
- **Schema versioning**: Safe, incremental evolution
- **Single responsibility**: Clear ownership per cell
- **Reusability**: Cells usable across apps and features
- **Horizontal scalability**: Scale hot cells independently
- **Observability**: Correlation IDs and structured logging
- **Language flexibility**: Cells in Dart, Rust, etc.
- **UI discipline**: UI cells stay presentation‑only (e.g., Riverpod for state in Dart UIs)

---

### Advantages

- **Faster iteration**: Change one cell without fear of side effects
- **Safer refactors**: Versioned contracts prevent breakage
- **Parallel work**: Teams operate on different cells concurrently
- **Lower complexity**: Smaller, focused codebases per cell
- **Better testing**: Unit tests per cell; integration via the bus
- **Incremental adoption**: Wrap legacy with integration cells and migrate gradually

---

### Example refinement

Goal: Add OTP to login.

- Update `auth_logic` spec to `auth.login.v2` adding `otp`.
- Implement and test inside `auth_logic`.
- `auth_ui` begins emitting `auth.login.v2` when ready; until then, continue sending `v1`.
- Both versions can be supported temporarily by `auth_logic` or via a shim cell.

No broad rewrites; only cell‑local changes and contract updates.

---

### When to still write big specs

- Cross‑cell policy and governance (security, compliance)
- Global invariants (idempotency, consistency levels)
- System‑wide message catalogs and subject naming

CBS narrows “big specs” to architecture and policy, not entangled implementation.

---

### Where to go next

- Architecture and flows: `framework/docs/architecture.md`, `framework/docs/message_flows.md`
- Contracts and subjects: `framework/docs/subject-naming.md`, `framework/docs/schemas/`
- Tools and workflow: `cbs-agent/README.md` and `cbs-agent/scripts/`

Build cells, not monoliths. Let the bus do the coupling—and keep refinement easy.


