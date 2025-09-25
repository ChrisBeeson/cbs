## LLM Tripwires and Conventions

### Do/Don’t
- Do use snake_case for `service` and `verb`. Don’t mix cases.
- Do derive subject as `cbs.{service}.{verb}`. Don’t hardcode reply subjects.
- Do send one responsibility per cell. Don’t couple multiple verbs into one handler.
- Do use NATS request API. Don’t invent custom reply routing.
- Do return a single success payload or an `error` object. Don’t mix both.
- Do set unique uuid v4 for `Envelope.id`. Don’t reuse ids.
- Do keep payload matching `schema`. Don’t drift from declared version.
- Do use queue group = `{service}`. Don’t use unique groups per instance unless testing.
- Do assume NATS must be running for tests. Don’t skip starting it locally/CI.
- Do avoid duplicate cells on the same subject unless for scaling. Don’t create conflicting handlers.

### Naming
- Subjects, `service`, `verb`: lowercase snake_case.
- Crate/module names should mirror paths (e.g., `cells/examples/greeter_rs`). Ensure crate names in code match Cargo manifests and imports.

### Timeouts
- Use a single default request timeout in the bus. Override per-call only when necessary.

### Observability
- Always log/trace with `id`, `service`, `verb` for correlation.

### Changes That Require Doc Updates
- New/changed subjects, schema versions, timeouts, error codes, or queue groups.


