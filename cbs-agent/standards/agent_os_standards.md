# CBS Agent-OS Standards

## Core Philosophy: Cell-Based Development

When working with CBS applications, agents MUST adopt cell-based thinking and maintain biological isolation at all times.

### The Cardinal Rule
**CELLS MUST ONLY COMMUNICATE THROUGH THE BUS - NEVER DIRECTLY**

### Development Principles
- **Cell-focused**: Always work within the context of specific cells
- **Bus-only communication**: No direct imports or method calls between cells
- **Contract-first**: Design message contracts before implementation
- **Isolation preservation**: Maintain biological isolation in all changes

### Tooling
- CI: fmt, clippy, tests on PRs and main
- PR hygiene: checklists and Conventional Commits
- Pre-commit: whitespace, YAML/JSON checks, Rust fmt/clippy

### Docs
- Update `ai/docs/*` and `README.md` with meaningful changes.
- Document major functions/refactors within the changed files.

## Agent-OS Workflow

### Required Context Management
Agents MUST maintain application and cell context using CBS Agent-OS commands:

```bash
# Set application context
cbs-app-context <app_name>

# Focus on specific cell
cbs-cell-focus <cell_name>

# Start cell-focused work session
cbs-work-start <app> <cell>
```

### Cell Development Workflow
1. **Set Context**: Always establish app/cell context before work
2. **Review Spec**: Check `ai/spec.md` for message contracts
3. **Validate Isolation**: Ensure no direct cell dependencies
4. **Implement Changes**: Work within cell boundaries only
5. **Test Isolation**: Validate bus-only communication
6. **Update Contracts**: Modify specs when changing messages

### Spec & Birthmap Conventions
- Per cell: `cells/<cell_id>/ai/spec.md` is the root spec defining message contracts
- Per app: `applications/<app>/birthmap.yaml` lists cells and message flows
- Runtime config: `app.yaml` for CBS framework loader
- **CRITICAL**: Cells remain bus-only; no direct cell-to-cell communication

### Cell Implementation Standards
- **Supported languages**: Rust, Dart/Flutter, Python
- **Rust cells**: Use `cargo fmt`, `cargo clippy`, `cargo test`
- **Dart cells**: Use `flutter analyze`, `flutter test`, `dart format`
- **Python cells**: Use Ruff for linting, Black for formatting, PyTest for testing
- **Cell structure**: Keep cohesive, self-contained, with clear message boundaries
- **No cross-cell dependencies**: Each cell must be independently testable

## Agent-OS Commands

### Context Management
- `cbs-app-context <app>` - Set application context
- `cbs-cell-focus <cell>` - Focus on specific cell
- `cbs-work-start <app> <cell>` - Start cell-focused work session
- `cbs-work-start --status` - Show current work context

### Cell Operations
- `cbs-cell-list` - List cells in current application
- `cbs-cell-messages [cell]` - Show cell's message contracts
- `cbs-validate-isolation` - Validate current cell (or `--app`, `--all`)

### Validation & Guards
- `cbs-validate-isolation --all` - Check all cells for violations
- Optional project hooks may additionally block cross-cell imports (if present)

## Agent Behavior Rules

### Before Making Any Changes
1. **Check context**: `cbs-work-start --status`
2. **Validate current cell**: `cbs-validate-isolation`
3. **Review message contracts**: `cbs-cell-messages`

### When Creating New Features
1. **Design messages first** in `ai/spec.md`
2. **Set cell focus**: `cbs-cell-focus <cell>`
3. **Implement within cell boundaries only**
4. **Test isolation**: `cbs-validate-isolation`

### When Debugging Issues
1. **Use correlation IDs** for message tracing
2. **Check message contracts** for compatibility
3. **Validate bus-only communication**
4. **Test with mock bus first**

### Milestones
- Validate isolation before milestone commits


