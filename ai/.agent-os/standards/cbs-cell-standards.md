# CBS Cell Standards

These rules enforce how we work in the Cell Body System (CBS).

- **Bus-Only Communication**: Cells MUST ONLY communicate through the bus - never direct cell-to-cell calls.
- **Modular Design**: Cells can be large and contain internal components, but must be modular, reusable, and expandable.
- **Single responsibility**: One clear capability per cell.
- **Spec-first**: Each cell has an `ai/spec.md` root and optional sub-specs (API, DB, technical, tests). Implementations follow the spec.
- **Contracts**: Subjects follow `cbs.<service>.<verb>`; include version in schema when relevant (e.g. `service.verb.v1`).
- **Logging**: Use platform logging (`log.d/i/w/e` in Flutter; keep logs concise).
- **Testing**: Unit tests for logic; integration tests for bus handling. Avoid cross-cell tests—use bus messages.
- **Internal Structure**: Organize code within cells modularly with clear separation of concerns.
- **Docs**: Keep `spec.md` accurate. Update when behavior changes. Prefer short, precise wording.

## Required Spec fields

- `id`, `name`, `version`, `language`, `category`, `purpose`
- Interface: list of `subjects` (subscribe/publish) and envelope type
- Tests: brief checklist of behaviors

See `ai/docs/schemas/cell_dna.schema.json` and validator.

## Directory layout (per application)

```
applications/<app>/cells/<cell>/
  ai/spec.md
  lib/...
  test/...
  pubspec.yaml (Dart)
```

Polyglot cells live in `shared_cells/<lang>/` for reuse.

## Allowed cell categories

- `ui`, `io`, `logic`, `integration`, `storage`

## Subject and schema rules

- Subject: `cbs.<service>.<verb>` only
- Include schema/versioning in envelope metadata where applicable
- Errors publish error envelopes with clear `schema` and message

## Validation and tools

- **Bus Communication**: Focus validation on ensuring proper bus usage patterns
- **Specs**: `ai/scripts/validate_spec.py` validates `spec.md`
- **Mapping**: `ai/scripts/generate_cell_map.py` generates `ai/docs/cell_map.md`

## Multi-repo strategy

- Keep standards and scripts here canonical. Sync using `scripts/cbs_standards_sync.sh`.
- Shared logic should move to `shared_cells/` or separate shared SDK repos; cells depend only on bus contracts.


