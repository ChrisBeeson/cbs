# Cell Guard

Enforce that only files under a chosen cell directory are committed while you work in that cell.

## Commands

```bash
# Start guard for a cell (path relative to repo root)
./scripts/cell_guard.sh start applications/flutter_flow_web/cells/flow_ui

# Check status
./scripts/cell_guard.sh status

# Stop guard
./scripts/cell_guard.sh stop
```

## How it works
- Writes allowed prefix to `.cell_guard` in repo root
- Installs managed git hooks: `pre-commit`, `pre-push`
- Blocks commits/pushes if staged files are outside the allowed prefix

## Notes
- Opt-in per developer; do not commit `.cell_guard`
- Switch cells by running `start` with a new path
- If execution bit is missing: `bash scripts/cell_guard.sh start <path>`

## CI (optional)
- You can invoke `scripts/cell_guard.sh hook` in CI to mirror the check
