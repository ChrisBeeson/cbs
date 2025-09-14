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

### Supabase & Riverpod
- Use Supabase MCP for DB; do not run migrations from CI.
- Prefer Riverpod for state; logging via `log.d/e/i/w()` from `../utils/logger.dart`.

### Milestones
- Use `scripts/milestone_commit.sh "feat(standards): describe milestone"` at the end of each major task.


