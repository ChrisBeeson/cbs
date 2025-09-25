---
description: Refine and iterate on individual CBS cell specifications
version: 1.0
encoding: UTF-8
---

# Refine CBS Cell Specification

## Overview

Iterate on individual CBS cell specifications, updating message contracts, responsibilities, or implementation details while maintaining proper cell isolation and bus-only communication.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="validate_cell_context">

### Step 1: Validate Cell Context

Ensure we have a valid cell to refine and proper context.

**Context Validation**:
```bash
# Check workflow state
if [ ! -f ".cbs-workflow-state" ]; then
  echo "❌ No workflow state found"
  echo "Initialize application first: cbs app create <app_name>"
  exit 1
fi

# Get current context
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)
CURRENT_PHASE=$(yq eval '.current_phase' .cbs-workflow-state)

# Validate cell name provided or get from context
if [ -z "$CELL_NAME" ]; then
  CURRENT_CELL=$(yq eval '.active_cell' .cbs-workflow-state)
  if [ -z "$CURRENT_CELL" ] || [ "$CURRENT_CELL" = "null" ]; then
    echo "❌ No cell specified and no active cell in context"
    echo "Usage: cbs cell refine <cell_name>"
    exit 1
  fi
  CELL_NAME="$CURRENT_CELL"
fi

# Check cell exists
CELL_SPEC_PATH="applications/$CURRENT_APP/cells/$CELL_NAME/.cbs-spec/spec.md"
if [ ! -f "$CELL_SPEC_PATH" ]; then
  echo "❌ Cell specification not found: $CELL_SPEC_PATH"
  echo "Create cell first: cbs cell design $CELL_NAME"
  exit 1
fi
```

**Phase Compatibility Check**:
- **cell_specs phase**: Direct refinement
- **implementation phase**: Warning about impact on code
- **Later phases**: Impact analysis on existing implementation

</step>

<step number="2" name="analyze_current_cell_spec">

### Step 2: Analyze Current Cell Specification

Parse the existing cell specification to understand current state.

**Specification Analysis**:
```bash
# Extract current cell details
CELL_ID=$(grep "^- \*\*ID\*\*:" "$CELL_SPEC_PATH" | cut -d: -f2 | xargs)
CELL_CATEGORY=$(grep "^- \*\*Category\*\*:" "$CELL_SPEC_PATH" | cut -d: -f2 | xargs)
CELL_LANGUAGE=$(grep "^- \*\*Language\*\*:" "$CELL_SPEC_PATH" | cut -d: -f2 | xargs)
CELL_PURPOSE=$(grep "^- \*\*Purpose\*\*:" "$CELL_SPEC_PATH" | cut -d: -f2- | xargs)

# Extract message contracts
SUBSCRIBE_SUBJECTS=$(grep -A 10 "### Subjects" "$CELL_SPEC_PATH" | grep "Subscribe" | cut -d: -f2 | xargs)
PUBLISH_SUBJECTS=$(grep -A 10 "### Subjects" "$CELL_SPEC_PATH" | grep "Publish" | cut -d: -f2 | xargs)
```

**Current State Summary**:
```markdown
## Current Cell State Analysis

### Cell Identity
- **ID**: $CELL_ID
- **Category**: $CELL_CATEGORY  
- **Language**: $CELL_LANGUAGE
- **Purpose**: $CELL_PURPOSE

### Message Contracts
- **Subscribes**: $SUBSCRIBE_SUBJECTS
- **Publishes**: $PUBLISH_SUBJECTS

### Dependencies
[Analysis of cells this cell communicates with]

### Implementation Status
[Check if cell is implemented, has tasks, etc.]
```

</step>

<step number="3" name="gather_refinement_requirements">

### Step 3: Gather Refinement Requirements

Collect specific changes the user wants to make to the cell.

**Refinement Categories**:

**🎯 Responsibility Changes**:
- Modify cell's primary purpose
- Add or remove functionality
- Change scope of responsibility
- Adjust single responsibility principle

**📨 Message Contract Changes**:
- Add new subjects to subscribe/publish
- Remove unnecessary message handling
- Change message schemas or formats
- Modify error handling patterns

**🔗 Communication Changes**:
- Change which cells this cell talks to
- Modify message flow patterns
- Update request-response vs event patterns
- Adjust queue group assignments

**🧪 Implementation Changes**:
- Change implementation language
- Modify testing requirements
- Update performance criteria
- Adjust error handling approach

**User Input Collection**:
```bash
echo "🔧 Cell Refinement - $CELL_NAME"
echo ""
echo "Current purpose: $CELL_PURPOSE"
echo "Current category: $CELL_CATEGORY"
echo ""
echo "What would you like to refine?"
echo "1. Cell responsibility/purpose"
echo "2. Message contracts (what it listens/sends)"
echo "3. Communication with other cells"
echo "4. Implementation approach"
echo "5. Other specific changes"
echo ""
echo "Describe your changes:"
```

</step>

<step number="4" name="validate_refinement_impact">

### Step 4: Validate Refinement Impact

Analyze how the proposed changes affect cell isolation and other cells.

**CBS Compliance Validation**:
- **Isolation Maintained**: Changes don't break cell boundaries
- **Bus-Only Communication**: No direct cell dependencies introduced
- **Single Responsibility**: Cell maintains clear, focused purpose
- **Message Contracts**: Changes follow CBS envelope patterns

**Inter-Cell Impact Analysis**:
```markdown
## Refinement Impact Analysis

### Direct Impact on $CELL_NAME
- **Responsibility Changes**: [How cell's job changes]
- **Interface Changes**: [New/removed message contracts]
- **Implementation Changes**: [How code will be affected]

### Impact on Other Cells
[For each cell that communicates with this cell]
- **[Other Cell Name]**: [How it's affected by changes]
  - Message contracts that need updating
  - Potential cascade changes needed
  - Testing impact

### Message Flow Changes
- **New Message Flows**: [New communication patterns]
- **Removed Message Flows**: [Communication no longer needed]
- **Modified Message Flows**: [Changed message contracts]

### Implementation Impact
- **Code Changes Required**: [Scope of implementation changes]
- **Test Updates Needed**: [Testing that needs updating]
- **Integration Testing**: [New integration tests needed]
```

**Risk Assessment**:
- **Breaking Changes**: Will this break existing functionality?
- **Cascade Effects**: Do other cells need to be updated?
- **Implementation Impact**: How much existing code is affected?

</step>

<step number="5" name="update_cell_specification">

### Step 5: Update Cell Specification

Apply the refinements to the cell specification document.

**Specification Update Process**:
1. **Create Iteration**: Start new iteration for this cell
2. **Backup Current**: Create snapshot before changes
3. **Apply Changes**: Modify spec.md with requested changes
4. **Update Metadata**: Increment version, update timestamps
5. **Document Changes**: Add iteration history to spec

**Updated Spec Structure**:
```markdown
# $CELL_NAME Cell Specification

## Metadata
- **ID**: $CELL_ID
- **Name**: [Updated if changed]
- **Version**: [Incremented version]
- **Language**: $CELL_LANGUAGE
- **Category**: $CELL_CATEGORY
- **Purpose**: [Updated purpose]
- **Last Updated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Interface
### Subjects
- **Subscribe**: [Updated subscription list]
- **Publish**: [Updated publication list]

### Message Schemas
[Updated message contract details]

## Implementation
### Core Logic
[Updated functionality description]

### Dependencies
[Updated cell communication requirements]

## Testing
[Updated test requirements]

## Iteration History
### Iteration [N] - $(date -u +%Y-%m-%d)
- **Changes**: [List of changes made]
- **Reason**: [User's rationale for changes]
- **Impact**: [Assessment of change impact]
```

</step>

<step number="6" name="update_affected_cells">

### Step 6: Update Affected Cells (If Needed)

If changes affect other cells, update their specifications accordingly.

**Cascade Update Process**:
```bash
# For each affected cell
for affected_cell in $AFFECTED_CELLS; do
  echo "🔄 Updating affected cell: $affected_cell"
  
  # Update message contracts in affected cell specs
  AFFECTED_SPEC="applications/$CURRENT_APP/cells/$affected_cell/.cbs-spec/spec.md"
  
  # Update publish/subscribe subjects
  # Update message schemas
  # Document cascade changes
  
  echo "✅ Updated $affected_cell specification"
done
```

**Cascade Documentation**:
- Document why each cell was updated
- Track cascade changes in iteration history
- Validate that cascade changes maintain isolation
- Ensure message contracts remain consistent

</step>

<step number="7" name="validate_system_consistency">

### Step 7: Validate System Consistency

Ensure the refined cell specification maintains system-wide consistency.

**System Validation**:
```bash
# Run CBS validation suite
cbs validate --specs

# Check message contract consistency
cbs validate --envelopes

# Validate cell isolation
cbs isolation validate --app $CURRENT_APP

# Update cell map
cbs validate --map
```

**Consistency Checks**:
- **Message Contracts**: All referenced subjects have publishers/subscribers
- **Cell Dependencies**: No circular dependencies created
- **Isolation Compliance**: Cell boundaries remain intact
- **Schema Versioning**: Message schemas are properly versioned

</step>

<step number="8" name="present_for_approval">

### Step 8: Present Refined Cell for Approval

Show the updated cell specification and system impact for user approval.

**Approval Presentation**:
```markdown
## 🧬 Cell Specification Refined

**Cell**: $CELL_NAME
**Application**: $CURRENT_APP
**Iteration**: [N]

### 📝 Changes Summary
[Detailed summary of what was changed]

### 🔄 Message Contract Changes
- **New Subscriptions**: [List new subjects]
- **New Publications**: [List new subjects]
- **Removed Contracts**: [List removed subjects]
- **Modified Schemas**: [List changed message formats]

### 🧬 Affected Cells
[List of other cells that were updated due to cascade effects]

### ✅ Validation Results
- Cell Specification: ✅ Valid
- Message Contracts: ✅ Consistent
- Cell Isolation: ✅ Maintained
- System Integration: ✅ Compatible

### 📄 Updated Specification
Location: `applications/$CURRENT_APP/cells/$CELL_NAME/.cbs-spec/spec.md`

### 🔄 Your Options
1. **Approve**: Accept changes and continue
2. **Further Refine**: Make additional changes
3. **Rollback**: Return to previous cell specification

**What would you like to do?**
```

</step>

<step number="9" name="finalize_or_iterate">

### Step 9: Finalize or Continue Iteration

Handle user decision and either finalize changes or continue iterating.

**Finalization Process** (on approval):
```bash
# Mark cell refinement as complete
yq eval "
  .phases.cell_specs.cells += [\"$CELL_NAME\"] |
  .phases.cell_specs.status = \"in_progress\"
" .cbs-workflow-state

# Update CBS context if this was active cell
cbs focus $CELL_NAME

echo "✅ Cell $CELL_NAME specification finalized"
echo "🧬 Cell ready for implementation or further development"
```

**Iteration Process** (on further changes):
```bash
# Continue refinement loop
echo "🔄 Continuing refinement of $CELL_NAME..."
# Return to step 3 with new requirements
```

**Integration with Workflow**:
- Updates workflow state with cell changes
- Maintains iteration history for cell
- Creates snapshots for rollback capability
- Integrates with overall application workflow

</step>

</process_flow>

## Advanced Features

### **Smart Suggestions**:
- Analyze current spec and suggest improvements
- Identify potential message contract optimizations
- Recommend cell responsibility refinements
- Suggest testing approach improvements

### **Impact Visualization**:
- Show ASCII diagram of message flow changes
- Display cell dependency graph updates
- Highlight cascade effects on other cells
- Show implementation effort estimates

### **Rollback Granularity**:
- Rollback just this cell to previous iteration
- Rollback entire application to before cell changes
- Selective rollback of specific changes
- Preview rollback impact before executing

This instruction provides powerful, intuitive cell refinement that maintains CBS principles while supporting unlimited iterations and proper impact management.
