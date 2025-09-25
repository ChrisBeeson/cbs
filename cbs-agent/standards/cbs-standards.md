# CBS Development Standards

## Core Philosophy: Cell-Based Development

**CELLS MUST ONLY COMMUNICATE THROUGH THE BUS - NEVER DIRECTLY**

### Development Principles
- **Cell-focused**: Always work within the context of specific cells
- **Bus-only communication**: No direct imports or method calls between cells  
- **Contract-first**: Design message contracts before implementation
- **Isolation preservation**: Maintain biological isolation in all changes
- **Modular design**: Cells can be large internally but must be reusable and expandable

## Cell Standards

### Required Spec Fields
- `id`, `name`, `version`, `language`, `category`, `purpose`
- Interface: list of `subjects` (subscribe/publish) and envelope type
- Tests: brief checklist of behaviors

### Cell Categories
- `ui`, `io`, `logic`, `integration`, `storage`

### Directory Structure
```
applications/<app>/cells/<cell>/
  .cbs-spec/spec.md   # Cell specification
  lib/               # Implementation
  test/              # Tests
  pubspec.yaml       # Dependencies (Dart)
```

### Message Contracts
- Subject format: `cbs.<service>.<verb>` (snake_case)
- Schema versioning: `service.verb.v1` in envelope metadata
- Envelope structure: JSON with `schema`, `payload`, `correlation_id`
- Error handling: Publish error envelopes with clear messages
- See `framework/docs/subject-naming.md` for naming conventions and service suffix guidance

### Quality Standards
- **Logging**: Use platform logging (`log.d/i/w/e` in Flutter; keep logs concise)
- **Testing**: Unit tests for logic; integration tests for bus handling
- **Bus-only rule**: Never communicate directly between cells
- **Internal modularity**: Within cells, organize code modularly
- **Documentation**: Keep `.cbs-spec/spec.md` accurate; update when behavior changes

## Code Style

### Rust
- Use `rustfmt` defaults; CI runs `cargo fmt -- --check`
- Lint with `clippy`; fix or allow with rationale
- Prefer explicit types on public APIs; avoid `unwrap`/`expect` in library code
- Use early returns; handle errors with `thiserror` or `anyhow`
- Keep modules small; one responsibility per file

### Dart/Flutter  
- Follow `dart format`; CI runs `flutter analyze` and `flutter test`
- Prefer immutable data, small widgets/functions
- Use explicit types for public APIs; avoid dynamic
- Keep files short; one widget/class per file when feasible
- Document public classes and functions concisely
- **Color opacity**: Use `color.withValues(alpha: 0.5)` instead of deprecated `withOpacity()`
- **Null safety**: Use late initialization and proper null checks
- **Widget lifecycle**: Properly dispose controllers and notifiers
- **State management**: Use ValueNotifier for reactive updates in CBS cells

### Python
- Format with Black (line length 100); lint with Ruff
- Python >= 3.11, prefer type hints on public functions
- Use `pytest` for tests; keep tests close to code
- Avoid complex metaprogramming; choose readability
- Small, focused modules; clear names; early returns

## Development Workflow

### Context Management
```bash
cbs context <app_name>          # Set application context
cbs focus <cell_name>           # Focus on specific cell  
cbs work <app> <cell>           # Start work session
```

### Cell Development
1. **Set Context**: Establish app/cell context before work
2. **Review Spec**: Check `.cbs-spec/spec.md` for message contracts
3. **Validate Isolation**: Ensure no direct cell dependencies
4. **Implement Changes**: Work within cell boundaries only
5. **Test Isolation**: Validate bus-only communication
6. **Update Contracts**: Modify specs when changing messages

### Validation
```bash
cbs validate                    # Full validation suite
cbs validate --specs           # Specs only
cbs isolation                  # Check cell isolation
cbs validate-code-isolation    # Check code-level isolation for Rust and Dart
cbs realtime-feedback          # Real-time CBS compliance feedback during development
cbs bus-simulator              # Simulate bus interactions for testing
```

## Tech Stack

### Core Infrastructure
- **Message Bus**: NATS with JetStream persistence
- **Database**: Supabase PostgreSQL with MCP integration
- **Subject Pattern**: `cbs.{service}.{verb}` with queue groups

### Languages & Runtimes
- **Primary**: Rust 2021 Edition
- **UI**: Dart/Flutter SDK >=3.0.0 <4.0.0
- **Polyglot**: Python >=3.11 (via cells)

### Key Dependencies
#### Rust
- serde/serde_json, async-trait, async-nats, tokio, uuid, thiserror

#### Dart/Flutter
- CBS SDK (custom cell framework), HTTP & WebSocket clients

### Development Tools
- **Formatting**: rustfmt, dart format, Black
- **Linting**: clippy, flutter_lints, Ruff
- **Testing**: Built-in test frameworks + mockito
- **Observability**: log.d/i/w/e with correlation IDs

## Best Practices

### Keep It Simple
- Implement in fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on single responsibility
- Group related functionality together
- Use consistent naming conventions

## Breaking Changes Protocol

When making breaking changes:
1. **Version Bump**: Increment major version (1.0.0 → 2.0.0)
2. **Message Versioning**: Add version to message names (`service.verb.v2`)
3. **Migration Plan**: Document how dependent cells adapt
4. **Backward Compatibility**: Consider supporting old subjects temporarily

## New Enforcement Tools

To ensure strict adherence to CBS principles, the following tools have been added:

- **Code Isolation Validation**: Use `cbs validate-code-isolation` to statically analyze Rust and Dart code for direct cell dependencies or imports, enforcing bus-only communication.
- **Message Contract Validation**: Enhanced `generate_cell_map.py` to validate that all published subjects have corresponding subscribers and vice versa, preventing orphaned messages.
- **Real-Time Feedback**: Use `cbs realtime-feedback` to get immediate warnings during development if CBS principles are violated, such as direct cell communication attempts.
- **Bus Simulation Testing**: Use `cbs bus-simulator` to simulate bus interactions, testing cell communication without a real bus to ensure proper message handling.

These tools are integrated into the development workflow to provide continuous enforcement of CBS standards at every stage of development.
