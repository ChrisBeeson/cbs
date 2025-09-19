## Agent OS Standards for CBS

### Principles
- Small, focused files; clear ownership.
- Concise code; no speculative edge cases.
- Preserve existing logic; refactors must be behavior-safe.

### Tooling
- CI: fmt, clippy, tests on PRs and main.
- PRs must have all checklist items checked.
- Conventional Commit PR titles.
- Pre-commit: whitespace, YAML/JSON checks, Rust fmt/clippy.

### Docs
- Update `ai/docs/*` and `README.md` with meaningful changes.
- Document major functions/refactors within the changed files.

### Spec & Birthmap Conventions
- Per cell: `cells/<cell_id>/ai/spec.md` is the root spec for LLM regeneration. Additional AI docs can live beside it (e.g., `cells/<cell_id>/ai/ui.md`, `schemas.md`, `error-cases.md`).
- Per app: `applications/<app>/birthmap.yaml` lists concrete cells, deps, flows for orchestration.
- Runtime stays on `app.yaml` (loader-compatible). Spec and birthmap are agent-facing specs.
- Cells remain bus-only; no direct cell-to-cell communication. Cells can be modular and contain internal components.

### Cells
- Supported cells: Python and Flutter/Dart.
- Python cells: lint with Ruff, format with Black, test with PyTest.
- Flutter cells: `flutter analyze`, `flutter test`.
- Keep cell code minimal and cohesive per directory.

### Milestones
- Use `scripts/milestone_commit.sh "feat(cells): describe milestone"` at the end of each major task.


