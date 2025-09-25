# CBS Agent-OS Guide: Cell-Based Development Workflow

This guide explains how to use the CBS Agent-OS system to maintain cell-based thinking and biological isolation while developing applications.

## Why Agent-OS for CBS?

Traditional development tools think in terms of files and modules. CBS requires thinking in terms of **cells** and **message contracts**. The Agent-OS system enforces this paradigm shift by:

- **Maintaining context** of current application and cell
- **Enforcing isolation** through validation tools
- **Guiding workflow** with cell-focused commands
- **Preventing violations** of the bus-only communication rule

## Quick Start

### 1. Set Application Context
```bash
# List available applications
cbs-app-context --list

# Set context for an application
cbs-app-context flutter_flow_web
```

### 2. Focus on a Cell
```bash
# List cells in current application
cbs-cell-list

# Focus on specific cell
cbs-cell-focus flow_ui
```

### 3. Start Working
```bash
# Start a complete work session
cbs-work-start flutter_flow_web flow_ui

# Check current status
cbs-work-start --status
```

## Core Commands

Available commands in this repository:

- `cbs-app-context`
- `cbs-cell-focus`
- `cbs-cell-list`
- `cbs-cell-messages`
- `cbs-validate-isolation`
- `cbs-work-start`

### Context Management

#### `cbs-app-context`
Manages application context for cell-based development.

```bash
# Set application context
cbs-app-context flutter_flow_web

# List available applications
cbs-app-context --list

# Show current context
cbs-app-context --status

# Clear context
cbs-app-context --clear
```

#### `cbs-cell-focus`
Sets focus on a specific cell within the current application.

```bash
# Focus on a cell
cbs-cell-focus flow_ui

# List cells in current app
cbs-cell-focus --list

# Show current focus
cbs-cell-focus --status

# Clear cell focus
cbs-cell-focus --clear
```

#### `cbs-work-start`
Combines app context and cell focus for a complete work session.

```bash
# Start working on specific cell
cbs-work-start flutter_flow_web flow_ui

# Show work session status
cbs-work-start --status

# Stop work session
cbs-work-start --stop
```

### Cell Information

#### `cbs-cell-list`
Lists all cells in the current application with details.

```bash
# List cells with types and descriptions
cbs-cell-list
```

#### `cbs-cell-messages`
Shows message contracts for a cell.

```bash
# Show contracts for specific cell
cbs-cell-messages flow_ui

# Show contracts for current cell
cbs-cell-messages
```

### Validation & Isolation

#### `cbs-validate-isolation`
Validates that cells maintain biological isolation.

```bash
# Validate current cell
cbs-validate-isolation

# Validate specific cell
cbs-validate-isolation flow_ui

# Validate all cells in current app
cbs-validate-isolation --app

# Validate entire project
cbs-validate-isolation --all
```

## Development Workflows

### Creating a New Feature

1. **Set Context**
   ```bash
   cbs-app-context my_app
   ```

2. **Focus on Cell**
   ```bash
   # Focus on the cell you will change
   cbs-cell-focus user_service
   ```

3. **Design Message Contracts**
   ```bash
   # Review current contracts
   cbs-cell-messages user_service
   
   # Edit specification
   # Update .cbs-spec/spec.md with new message contracts
   ```

4. **Implement Changes**
   ```bash
   # Start focused work session
   cbs-work-start my_app user_service
   
   # Make changes within cell boundaries only
   # Remember: bus-only communication!
   ```

5. **Validate Isolation**
   ```bash
   # Check cell isolation
   cbs-validate-isolation
   ```

### Debugging Issues

1. **Check Current Context**
   ```bash
   cbs-work-start --status
   ```

2. **Validate Isolation**
   ```bash
   cbs-validate-isolation --app
   ```

3. **Review Message Contracts**
   ```bash
   cbs-cell-messages problematic_cell
   ```

4. **Trace Message Flows**
   - Use correlation IDs in logs
   - Use your bus monitor tooling to trace messages

### Refactoring Cells

1. **Set Cell Focus**
   ```bash
   cbs-cell-focus target_cell
   ```

2. **Review Current Contracts**
   ```bash
   cbs-cell-messages target_cell
   ```

3. **Validate Before Changes**
   ```bash
   cbs-validate-isolation
   ```

4. **Make Isolated Changes**
   - Work within cell boundaries only
   - Preserve message contracts unless explicitly changing
   - Test each change in isolation

5. **Validate After Changes**
   ```bash
   cbs-validate-isolation
   ```

## Context Files

The Agent-OS system maintains context in `.cbs-context` file:

```bash
# CBS Agent-OS Context
CBS_CURRENT_APP="flutter_flow_web"
CBS_CURRENT_CELL="flow_ui"
CBS_WORK_MODE="cell_focused"
CBS_CONTEXT_SET_AT="2024-01-01T12:00:00Z"
```

**Note**: This file should not be committed to version control.

## Validation Rules

The isolation validator checks for:

### ❌ Violations (Must Fix)
- Direct imports between cells
- Shared state between cells
- Direct method calls between cells
- Missing cell specifications

### ⚠️ Warnings (Should Review)
- No bus communication detected
- Missing message contracts
- Relative imports that might cross boundaries

### ✅ Good Practices
- Bus-based communication only
- Well-defined message contracts
- Cell specifications present
- Isolated, testable cells

## Integration with Development

### IDE Integration
Add to your shell profile:
```bash
# CBS Agent-OS shortcuts
alias cbs-app='cbs-app-context'
alias cbs-cell='cbs-cell-focus' 
alias cbs-work='cbs-work-start'
alias cbs-check='cbs-validate-isolation'

# Show CBS context in prompt
export PS1="[CBS: \$(cbs-app --status 2>/dev/null | grep 'Application:' | cut -d: -f2 | xargs)/\$(cbs-cell --status 2>/dev/null | grep 'Cell:' | cut -d: -f2 | xargs)] \$PS1"
```

### Pre-commit Hooks
Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Validate CBS isolation before commit
if ! cbs-validate-isolation --all; then
    echo "❌ CBS isolation violations found. Fix before committing."
    exit 1
fi
```

### CI/CD Integration
Add to your CI pipeline:
```yaml
- name: Validate CBS Isolation
  run: |
    cbs-validate-isolation --all
    if [ $? -ne 0 ]; then
      echo "CBS isolation violations detected"
      exit 1
    fi
```

## Best Practices

### Always Start with Context
```bash
# Good workflow
cbs-work-start my_app my_cell
# Now make changes...

# Bad workflow
# Just start editing files without context
```

### Validate Before and After Changes
```bash
# Before making changes
cbs-validate-isolation

# Make your changes...

# After making changes
cbs-validate-isolation
```

### Use Message Contracts as Documentation
```bash
# Always check contracts before integration
cbs-cell-messages source_cell
cbs-cell-messages target_cell
```

### Test in Isolation First
- Run your language-specific tests within the cell directory
- Then run integration tests against the bus as appropriate

## Troubleshooting

### "No application context set"
```bash
# Solution: Set application context
cbs-app-context --list
cbs-app-context <app_name>
```

### "Cell not found"
```bash
# Solution: Check available cells
cbs-cell-list
cbs-cell-focus <correct_cell_name>
```

### "Isolation violations detected"
```bash
# Solution: Fix violations
cbs-validate-isolation --app
# Review violations and remove direct dependencies
```

### "No message contracts defined"
```bash
# Solution: Update cell specification
# Edit .cbs-spec/spec.md and add message contracts
```

## Advanced Usage

### Custom Validation Rules
Extend `cbs-validate-isolation` for project-specific rules.

### Message Flow Analysis
Use bus monitoring to trace message flows between cells.

### Automated Testing
Integrate validation into your test suite for continuous isolation checking.

## Remember

The CBS Agent-OS system exists to enforce one critical principle:

**🧬 CELLS MUST ONLY COMMUNICATE THROUGH THE BUS - NEVER DIRECTLY**

Every command, validation, and workflow is designed to maintain this biological isolation that makes CBS revolutionary. Trust the system, embrace cell-based thinking, and let the bus handle all communication! 🚌
