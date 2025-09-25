---
description: Create a CBS cell from spec template
version: 1.0
encoding: UTF-8
---

# Create Cell (CBS)

## Overview

Create a new cell scaffold with `.cbs-spec/spec.md`, tests, and enforcement hooks.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="collect_inputs">

### Step 1: Inputs
- app name (existing under applications/)
- cell id (snake_case)
- language (dart/rust/python)
- category (ui|io|logic|integration|storage)
- brief purpose (1 sentence)

</step>

<step number="2" name="scaffold">

### Step 2: Scaffold
Create directories:
```
applications/<app>/cells/<cell>/
  .cbs-spec/spec.md
  lib/
  test/
```
Create minimal `spec.md` with required fields.

</step>

<step number="3" name="integrate_with_workflow">

### Step 3: Integrate with Workflow State
- Update workflow state to include new cell
- Set cell status to "spec_pending" in workflow
- Add cell to application's cell list
- Update CBS application context

</step>

<step number="4" name="validate">

### Step 4: Validate Cell Structure
- Run `cbs validate --specs` to validate cell specification
- Check CBS compliance (bus-only communication, proper isolation)
- Verify cell follows category standards
- Fix any validation issues

</step>

<step number="5" name="update_cell_map">

### Step 5: Update Cell Documentation
- Run `cbs validate --map` to update cell map
- Generate cell catalog entry if shareable
- Update application documentation
- Commit initial cell scaffold

</step>

</process_flow>
