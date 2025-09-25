# Cell Guard (DEPRECATED)

**⚠️ DEPRECATED**: This strict isolation approach is no longer recommended. Cells can now be larger and contain internal components. The only requirement is that cells MUST communicate via bus only.

This documentation is kept for backward compatibility.

## Commands

```bash
# Start guard for a cell (path relative to repo root)
./scripts/cell_guard.sh start applications/flutter_flow_web/cells/flow_ui

# Check status
./scripts/cell_guard.sh status

# Stop guard
./scripts/cell_guard.sh stop
```

### Optional: Import guard (block cross-cell imports)

```bash
# Add to .git/hooks/pre-commit (after cell_guard) or run manually
scripts/cell_import_guard.sh hook
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
 - You can also run `scripts/cell_import_guard.sh hook` in CI to prevent cross-cell imports
