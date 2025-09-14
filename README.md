# Cell Body System (CBS) — MVP

## Quick Start
1. Start NATS:
```bash
docker run -d --name nats-server -p 4222:4222 nats:latest
```
2. Run demo:
```bash
cargo run -p body
```
3. Tests:
```bash
cargo test --workspace
```

## Docs
- Master Spec: `ai/master_build_specs.md` (see §13 for NATS setup)
- Data Flows: `ai/docs/data_flows.md`
- LLM Tripwires: `ai/docs/llm_tripwires.md`
- Envelope Schema: `ai/docs/schemas/envelope.schema.json`
- Error Codes: `ai/docs/error_codes.md`
- Agent OS Standards: `ai/docs/agent_os_standards.md`

## Validate Envelopes
```bash
./ai/scripts/validate_envelopes.sh
```



