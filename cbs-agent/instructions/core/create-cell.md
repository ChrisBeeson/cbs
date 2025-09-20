---
description: Create a CBS cell from spec template
version: 1.0
encoding: UTF-8
---

# Create Cell (CBS)

## Overview

Create a new cell scaffold with `ai/spec.md`, tests, and enforcement hooks.

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
  ai/spec.md
  lib/
  test/
```
Create minimal `spec.md` with required fields.

</step>

<step number="3" name="guards">

### Step 3: Guards
- Enable commit guard: `scripts/cell_guard.sh start applications/<app>/cells/<cell>`
- Recommend import guard: add `scripts/cell_import_guard.sh` to pre-commit chain if desired

</step>

<step number="4" name="validate">

### Step 4: Validate
- Run `python3 ai/scripts/validate_spec.py`
- Fix missing required fields

</step>

<step number="5" name="map">

### Step 5: Update Map
- Run `python3 ai/scripts/generate_cell_map.py`

</step>

</process_flow>
