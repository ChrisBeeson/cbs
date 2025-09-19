---
description: Modify existing CBS cell spec specification
version: 1.0
encoding: UTF-8
---

# Modify Cell Spec (CBS)

## Overview

Update an existing cell's `ai/spec.md` specification with validation and regeneration.

<cbs_context_check>
  EXECUTE: @.agent-os/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="identify_cell">

### Step 1: Identify Cell
- app path: `applications/<app>/cells/<cell>`
- verify `ai/spec.md` exists
- backup current spec (optional)

</step>

<step number="2" name="modify_spec">

### Step 2: Modify Specification
Common modifications:
- **Messages this cell listens for** (subscribe): what messages trigger this cell to act
- **Messages this cell sends out** (publish): what messages this cell broadcasts to others
- **Message schemas**: the data structure each message carries
- **Cell behavior**: change what the cell actually does
- **Version**: bump version if breaking changes
- **Category**: change cell category if needed

Edit `ai/spec.md` directly or via guided prompts.

</step>

<step number="3" name="validate_changes">

### Step 3: Validate Changes
- Run `python3 ai/scripts/validate_spec.py applications/<app>/cells/<cell>/ai/spec.md`
- Fix any validation errors
- Ensure required fields are present

</step>

<step number="4" name="update_dependencies">

### Step 4: Update Dependencies
If message interface changed:
- **Check listeners**: find other cells that listen for messages you changed
- **Check senders**: find other cells that send messages you now listen for
- Update any dependent cell specs
- Consider backward compatibility

</step>

<step number="5" name="regenerate_map">

### Step 5: Regenerate Map
- Run `python3 ai/scripts/generate_cell_map.py`
- Verify cell appears correctly in updated map

</step>

<step number="6" name="test_spec">

### Step 6: Test Specification
- Run existing tests if cell is implemented
- Update tests if behavior changed
- Consider integration testing for interface changes

</step>

</process_flow>

## Breaking Changes

When making breaking changes:
1. **Version bump**: increment major version (e.g., 1.0.0 → 2.0.0)
2. **Message versioning**: add version to message names (e.g., `service.verb.v2`)
3. **Migration plan**: document how cells that send/receive these messages should adapt
4. **Backward compatibility**: consider listening for old message versions temporarily

## Quick Modifications

For non-breaking changes:
```bash
# Validate single cell
python3 ai/scripts/validate_spec.py applications/<app>/cells/<cell>/ai/spec.md

# Regenerate map
python3 ai/scripts/generate_cell_map.py
```
