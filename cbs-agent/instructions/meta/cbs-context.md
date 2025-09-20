---
description: CBS Context Template - Include CBS rules, methodology and standards
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# CBS Context Template

## CBS Core Principles

**Cell Body System (CBS)** follows modular biological principles:

- **🚌 Bus-Only Communication**: Cells MUST ONLY communicate through the bus - never direct cell-to-cell calls
- **📝 Spec-First**: Every cell has `ai/spec.md` defining its interface and behavior before implementation
- **🧩 Modular Design**: Cells can be large and contain internal components, but must be modular, reusable, and expandable
- **🏷️ Typed Contracts**: All messages use typed envelopes with `cbs.<service>.<verb>` subjects
- **🧪 Test-Driven**: Unit tests for logic, integration tests for bus handling

## CBS Cell Standards

### Required Spec Fields
Every `ai/spec.md` must include:
- `id`, `name`, `version`, `language`, `category`, `purpose`
- Interface: list of `subjects` (subscribe/publish) and envelope type
- Tests: brief checklist of behaviors

### Cell Categories
- **`ui`** - User interface components (Flutter, web)
- **`io`** - Input/output operations (file, network, stdio)  
- **`logic`** - Business logic and data processing
- **`integration`** - External service integrations (APIs, databases)
- **`storage`** - Data persistence and caching

### Directory Structure
```
applications/<app>/cells/<cell>/
  ai/spec.md          # Cell specification
  lib/               # Implementation
  test/              # Tests
  pubspec.yaml       # Dependencies (Dart)

shared_cells/<lang>/ # Reusable cells
  <cell>/
    ai/spec.md
    lib/
    test/
```

### Message Contracts
- **Subject Format**: `cbs.<service>.<verb>` (e.g., `cbs.flow_ui.render`)
- **Schema Versioning**: `service.verb.v1` in envelope metadata  
- **Envelope Structure**: JSON with `schema`, `payload`, `correlation_id`
- **Error Handling**: Publish error envelopes with clear messages

### Quality Standards
- **Logging**: Use platform logging (`log.d/i/w/e` in Flutter; keep logs concise)
- **Testing**: Unit tests for logic; integration tests for bus handling. Avoid cross-cell tests—use bus messages
- **Bus-Only Rule**: Never communicate directly between cells. All inter-cell communication MUST go through the bus
- **Internal Modularity**: Within cells, organize code modularly with clear separation of concerns
- **Reusability**: Design components to be reusable and expandable
- **Documentation**: Keep `spec.md` accurate. Update when behavior changes. Prefer short, precise wording

### Validation & Tools
- **Spec Validation**: `python3 ai/scripts/validate_spec.py` validates specs
- **Cell Mapping**: `python3 ai/scripts/generate_cell_map.py` generates documentation
- **Bus Communication**: Focus validation on ensuring proper bus usage patterns

### Breaking Changes Protocol
When making breaking changes:
1. **Version Bump**: Increment major version (1.0.0 → 2.0.0)
2. **Schema Versioning**: Add version to schemas (`service.verb.v2`)
3. **Migration Plan**: Document how dependent cells adapt
4. **Backward Compatibility**: Consider supporting old subjects temporarily

## CBS Workflows

### Add Feature to Application
1. **Analyze Feature**: Break down into modular cell opportunities
2. **Update Tasks**: Add to `ai/tasks.md`, document in `ai/history.md`
3. **Spec-First**: Update/create `ai/spec.md` files before coding
4. **Update Configuration**: Modify `birthmap.yaml` for dependencies/flows
5. **Implement**: Build modular cells following specs
6. **Validate**: Test bus communication, update cell map

### Create Cell: `create-cell.md`
1. Collect inputs (app, cell_id, language, category, purpose)  
2. Scaffold directories and spec.md
3. Validate spec
4. Update cell map

### Modify Cell: `modify-cell-spec.md`
1. Identify cell path
2. Edit ai/spec.md 
3. Validate changes
4. Update dependencies if interface changed
5. Regenerate cell map
6. Test specification

### Validation Commands
```bash
# Validate single cell
python3 ai/scripts/validate_spec.py applications/<app>/cells/<cell>/ai/spec.md

# Validate all cells
python3 ai/scripts/validate_spec.py

# Update cell map
python3 ai/scripts/generate_cell_map.py
```

## User Rules Integration

From user rules:
- Break code into manageable sized files
- Write concise, optimum code with as few lines as possible
- Don't delete/remove/change logic unless explicitly requested
- Avoid bloated code for rare edge cases
- Use Riverpod for state management
- Use `log.d()`, `log.e()`, `log.i()`, `log.w()` for logging (import from '../utils/logger.dart')
- All UI must fit the theme and be clean, modern with best design practices
- Include documentation on major functions and refactors
- When refactoring, put associated files in a directory
- Always scrutinize: are we doing it the best and simplest way with 100% effectiveness?
