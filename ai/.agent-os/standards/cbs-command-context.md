# CBS Command Context Standard

## Overview

All CBS-related commands MUST include CBS context to ensure consistent application of rules, methodology, and standards.

## Required Context Inclusion

Every CBS command file must include the CBS context check block immediately after the overview:

```markdown
<cbs_context_check>
  EXECUTE: @.agent-os/instructions/meta/cbs-context.md
</cbs_context_check>
```

## Commands Requiring CBS Context

### Core CBS Commands
- `create-cell.md` - Creating new cells
- `modify-cell-spec.md` - Modifying cell specifications
- `execute-cell-spec.md` - Executing cell specifications
- Any command that works with cells, specs, or CBS architecture

### Application Commands
- Commands working with applications that contain cells
- Commands modifying cell directories or structures
- Commands validating CBS compliance

## Context Content

The `cbs-context.md` template includes:
- CBS core principles (isolation, spec-first, single responsibility)
- Cell standards and categories
- Directory structures
- Message contracts and subject formats
- Quality standards and validation
- Breaking changes protocol
- CBS workflows and commands
- User-specific rules integration

## Benefits

Including CBS context ensures:
- Consistent application of CBS principles
- Proper understanding of cell isolation
- Correct subject naming and message contracts
- Appropriate validation and testing approaches
- Adherence to directory structures and standards
- Integration with user-specific development rules

## Implementation

When creating or modifying CBS commands:
1. Add the `<cbs_context_check>` block after the overview
2. Ensure the command logic aligns with CBS principles
3. Reference CBS standards in command steps
4. Include validation steps using CBS tools
5. Follow CBS directory and naming conventions
