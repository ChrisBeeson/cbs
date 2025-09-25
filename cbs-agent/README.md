# CBS Agent

Unified Cell Body System development tools and standards with **iterative development workflow support**.

## Quick Start - Friendly Commands

```bash
# Start a new app (workflow + app_spec.md)
cbs new app my_app

# Create a new cell spec (Spec‑Kit under specs/<date>‑<cell>/)
cbs new cell user_auth --app my_app --category logic --language dart

# Refine existing app or cell
cbs refine app my_app
cbs refine cell user_auth

# Optional: interactive wizard
cbs wizard
```

## Quick Start - New Iterative Workflow

```bash
# Create new CBS application with workflow tracking
cbs app-create my_new_app

# Check workflow status at any time
cbs status

# Create iterations as you refine specs
cbs iterate "Added user authentication requirements"

# Full workflow management
cbs workflow --help
```

## Traditional Quick Start

```bash
# Unified CLI tool
./cbs-agent/scripts/cbs --help

# Common workflows  
cbs work <app> <cell>           # Start working on a cell
cbs validate                    # Validate all specs and generate artifacts
cbs cell search --language dart # Find reusable cells
```

## Structure

- **`scripts/`** - Core CBS development tools
  - `cbs` - Unified CLI tool (primary interface)
  - `cbs-workflow` - **NEW**: Iterative workflow management
  - `cbs-*` - Individual tools for specific tasks
- **`instructions/`** - AI agent instructions for development workflows
  - **`workflows/`** - **NEW**: Iterative development workflows
- **`standards/`** - Consolidated CBS development standards
- **`templates/`** - Templates for new applications and cells
- **`specs/`** - Feature specifications and development history

## Enhanced Workflow System

### Multi-Cell Application Development
The CBS agent now supports complete **iterative development lifecycle**:

1. **Application Specification** - Define app purpose, features, users
2. **Cell Breakdown** - Break app into isolated, communicating cells  
3. **Cell Specifications** - Detail each cell's interface and behavior
4. **Implementation** - Generate tasks and build cells with TDD
5. **Feature Addition** - Add features through cell modifications

### Unlimited Iterations
- **Iterate at any phase** with complete state tracking
- **Rollback capability** to any previous iteration
- **Change history** with detailed documentation
- **No artificial limits** on iteration count

### Key Workflow Commands

```bash
# Application lifecycle
cbs app-create <app_name>         # Initialize new application
cbs status                        # Show current workflow status
cbs iterate "description"         # Create new iteration
cbs workflow rollback 2           # Rollback to iteration 2
cbs workflow history              # Show iteration history

# Phase management
cbs workflow app-spec             # Work on application spec
cbs workflow cell-breakdown       # Break down into cells
cbs workflow cell-specs           # Create individual cell specs
cbs workflow implementation       # Implement cells
cbs workflow feature-addition     # Add new features
```

## Traditional Tools (Still Available)

- `cbs validate` - Validate specs, envelopes, and generate cell maps
- `cbs cell` - Manage shareable cells (search, install, generate catalog)
- `cbs work <app> <cell>` - Set context and start focused development
- `cbs-app-spec <app>` - Create/update application specifications
- `cbs-regenerate-cell <app> <cell>` - Regenerate cell from specification

## Standards

All CBS development follows the standards in `standards/cbs-standards.md`:
- **Bus-only communication** - Cells never communicate directly
- **Spec-first development** - Define contracts before implementation
- **Cell isolation** - Maintain biological boundaries
- **Modular design** - Reusable, expandable components

## Cell Specifications

- Cell specs: `applications/<app>/cells/<cell>/ai/spec.md`
- App specs: `applications/<app>/ai/app_spec.md` (use template in `templates/`)
- Shared cells: Catalog managed via `cbs cell` commands

