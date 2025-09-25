---
description: Iterative Application Specification Development for CBS
version: 1.0
encoding: UTF-8
---

# Iterative Application Specification

## Overview

Create and refine application specifications through unlimited iterations, integrating with CBS workflow state management for complete traceability.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="check_workflow_state">

### Step 1: Check Workflow State

Verify current workflow state and ensure we're in the correct phase for application specification work.

**State Validation**:
- Check if `.cbs-workflow-state` exists
- Verify current phase is "app_spec" 
- Get current iteration count
- Identify application name and context

**Actions**:
```bash
# Check if workflow is initialized
if [ ! -f ".cbs-workflow-state" ]; then
  echo "⚠️ No workflow state found. Initialize first:"
  echo "cbs app-create <app_name>"
  exit 1
fi

# Get current state
CURRENT_PHASE=$(yq eval '.current_phase' .cbs-workflow-state)
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)
ITERATION=$(yq eval '.phases.app_spec.iteration' .cbs-workflow-state)
```

**Phase Transition Logic**:
- If not in "app_spec" phase, ask user if they want to transition
- If transitioning from later phase, warn about potential impact
- Update workflow state to "app_spec" phase if confirmed

</step>

<step number="2" name="determine_iteration_type">

### Step 2: Determine Iteration Type

Identify whether this is initial spec creation or iterative refinement.

**Iteration Types**:
- **Initial Creation** (iteration 0): No existing spec, create from scratch
- **Refinement** (iteration 1+): Existing spec, modify based on feedback
- **Major Revision** (user-requested): Significant changes to scope/features

**Decision Logic**:
```bash
APP_SPEC_PATH="applications/$CURRENT_APP/.cbs-spec/app_spec.md"

if [ ! -f "$APP_SPEC_PATH" ] || [ "$ITERATION" -eq 0 ]; then
  ITERATION_TYPE="initial"
else
  ITERATION_TYPE="refinement"
fi
```

**User Interaction**:
- For refinement: Ask what specific changes are needed
- For initial: Gather complete application requirements
- For major revision: Document scope of changes

</step>

<step number="3" name="gather_requirements">

### Step 3: Gather Requirements (Conditional)

Collect application requirements based on iteration type.

**For Initial Creation**:
1. **Application Purpose**: What problem does this solve?
2. **Target Users**: Who will use this application?
3. **Core Features**: What are the main capabilities?
4. **Technical Constraints**: Any specific requirements?
5. **Success Criteria**: How do we measure success?

**For Refinement**:
1. **Change Request**: What needs to be modified?
2. **Impact Analysis**: How does this affect existing features?
3. **User Feedback**: What prompted this change?
4. **Priority**: How urgent is this change?

**Requirement Capture Template**:
```markdown
## Iteration ${ITERATION} Requirements

### Change Type: [Initial|Refinement|Major Revision]

### Changes Requested:
- [Change 1]: [Description and rationale]
- [Change 2]: [Description and rationale]

### Impact Analysis:
- **Affected Sections**: [List spec sections that need updates]
- **New Requirements**: [Any new requirements introduced]
- **Removed Requirements**: [Any requirements being removed]

### User Approval Needed For:
- [ ] Updated application scope
- [ ] Modified feature list
- [ ] Changed success criteria
```

</step>

<step number="4" name="create_or_update_spec">

### Step 4: Create or Update Application Spec

Generate or modify the application specification based on gathered requirements.

**For Initial Creation**:
Use the enhanced app spec template:

```markdown
# Application Specification - ${APP_NAME}

## Overview
- **Purpose**: [1-2 sentence description]
- **Version**: 1.0.0
- **Created**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Last Updated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Application Details

### Target Users
- **Primary**: [User type and characteristics]
- **Secondary**: [Additional user types if applicable]

### Core Features
1. **[Feature Name]** - [Description and user value]
2. **[Feature Name]** - [Description and user value]
3. **[Feature Name]** - [Description and user value]

### Technical Requirements
- **Language**: [Primary implementation language]
- **Architecture**: Cell-based with bus-only communication
- **Platform**: [Web/Mobile/Desktop/CLI]
- **Integration**: [External services or systems]

### Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## Cell Architecture Preview

### Anticipated Cells
Based on features, we expect these cell categories:
- **UI Cells**: [Number] cells for user interface
- **Logic Cells**: [Number] cells for business logic
- **Integration Cells**: [Number] cells for external services
- **Storage Cells**: [Number] cells for data management

### Message Flow Patterns
- User interactions → UI cells → Logic cells → Storage/Integration cells
- All communication via CBS bus with typed envelopes
- No direct cell-to-cell communication

## Iteration History
### Iteration 0 - Initial Creation
- Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Changes: Initial application specification
- Status: Pending user approval
```

**For Refinement**:
1. **Load Existing Spec**: Read current app_spec.md
2. **Apply Changes**: Modify specific sections based on requirements
3. **Update Metadata**: Increment iteration, update timestamps
4. **Document Changes**: Add to iteration history section
5. **Preserve Structure**: Maintain existing format and organization

</step>

<step number="5" name="validate_specification">

### Step 5: Validate Specification

Ensure the specification is complete, consistent, and follows CBS principles.

**Validation Checks**:
- **Completeness**: All required sections present
- **Consistency**: Features align with success criteria
- **CBS Compliance**: Architecture follows cell-based principles
- **Feasibility**: Technical requirements are achievable
- **Clarity**: Language is clear and unambiguous

**CBS-Specific Validation**:
- Features can be reasonably decomposed into cells
- No features require direct cell-to-cell communication
- Message flow patterns are viable
- Cell categories make sense for the application type

**Validation Report**:
```markdown
## Specification Validation Report

### ✅ Passed Checks
- [x] All required sections present
- [x] Features align with user needs
- [x] CBS architecture principles followed
- [x] Success criteria are measurable

### ⚠️ Warnings
- Feature X may require complex message flow
- Integration with Y service needs clarification

### ❌ Issues Found
- Missing technical constraint for Z
- Success criteria #2 not measurable

### Recommendations
1. Add specific performance requirements
2. Clarify integration boundaries
3. Define error handling approach
```

</step>

<step number="6" name="update_workflow_state">

### Step 6: Update Workflow State

Update the workflow state file to reflect the current iteration and changes.

**State Updates**:
```bash
# Create new iteration in workflow state
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NEW_ITERATION=$((ITERATION + 1))

# Update state file
yq eval "
  .last_updated = \"$TIMESTAMP\" |
  .iteration_count = $NEW_ITERATION |
  .phases.app_spec.iteration = $NEW_ITERATION |
  .phases.app_spec.status = \"in_progress\" |
  .phases.app_spec.last_modified = \"$TIMESTAMP\" |
  .iterations += [{
    \"id\": $NEW_ITERATION,
    \"phase\": \"app_spec\",
    \"timestamp\": \"$TIMESTAMP\",
    \"description\": \"$CHANGE_DESCRIPTION\",
    \"changes\": [\"Updated app specification\"]
  }]
" .cbs-workflow-state > .cbs-workflow-state.tmp

mv .cbs-workflow-state.tmp .cbs-workflow-state
```

**Snapshot Creation**:
- Create snapshot of current state for rollback capability
- Include app spec file and workflow state
- Compress and store in `.cbs-snapshots/`

</step>

<step number="7" name="present_for_approval">

### Step 7: Present for User Approval

Show the updated specification to the user and get approval for next phase.

**Presentation Format**:
```markdown
## 📋 Application Specification Ready for Review

**Application**: ${APP_NAME}
**Iteration**: ${NEW_ITERATION}
**Phase**: app_spec

### 📝 Changes in This Iteration
${CHANGE_SUMMARY}

### 🎯 Current Specification Highlights
- **Purpose**: ${PURPOSE_SUMMARY}
- **Key Features**: ${FEATURE_COUNT} core features defined
- **Target Users**: ${USER_SUMMARY}
- **Architecture**: ${CELL_COUNT_ESTIMATE} anticipated cells

### 📄 Full Specification
Location: `applications/${APP_NAME}/.cbs-spec/app_spec.md`

### ✅ Validation Status
${VALIDATION_SUMMARY}

### 🔄 Next Steps Options
1. **Approve and Proceed**: Move to cell breakdown phase
2. **Request Changes**: Start new iteration with modifications
3. **Major Revision**: Significant changes to scope or approach

### 💬 User Decision Required
Please review the specification and choose:
- Type "approve" to proceed to cell breakdown
- Type "changes: [description]" to iterate
- Type "revision: [description]" for major changes
```

**Approval Handling**:
- **Approve**: Mark app_spec phase as completed, transition to cell_breakdown
- **Changes**: Start new iteration with user feedback
- **Revision**: Create major revision iteration with detailed change tracking

</step>

<step number="8" name="iteration_loop">

### Step 8: Iteration Loop Management

Handle unlimited iterations until user approves the specification.

**Iteration Flow**:
```
User Feedback → Requirements Analysis → Spec Updates → Validation → Presentation → User Decision
     ↑                                                                                    ↓
     ←←←←←←←←←←←←←←←← [Changes Requested] ←←←←←←←←←←←←←←←←←←←←←←←←←←
```

**Iteration Types**:
- **Minor Changes**: Small modifications to existing content
- **Feature Changes**: Adding, removing, or modifying features
- **Scope Changes**: Expanding or reducing application scope
- **Technical Changes**: Modifying technical requirements or constraints

**State Preservation**:
- Each iteration creates a snapshot
- Rollback available to any previous iteration
- Change history maintained in workflow state
- All iterations documented in spec file

**Iteration Limits**:
- No artificial limits on iteration count
- User controls when to proceed or abandon
- System maintains performance across unlimited iterations
- Cleanup of old snapshots based on retention policy

</step>

<step number="9" name="phase_transition">

### Step 9: Phase Transition (On Approval)

When user approves the specification, transition to the next workflow phase.

**Approval Actions**:
1. **Mark Phase Complete**: Set app_spec status to "completed"
2. **Update Timestamps**: Record completion time
3. **Create Final Snapshot**: Preserve approved state
4. **Transition Phase**: Move to "cell_breakdown" phase
5. **Initialize Next Phase**: Prepare for cell breakdown work

**State Transition**:
```bash
# Mark app_spec as completed and transition to cell_breakdown
yq eval "
  .current_phase = \"cell_breakdown\" |
  .phases.app_spec.status = \"completed\" |
  .phases.app_spec.completed_at = \"$TIMESTAMP\" |
  .phases.cell_breakdown.status = \"in_progress\" |
  .phases.cell_breakdown.started_at = \"$TIMESTAMP\"
" .cbs-workflow-state > .cbs-workflow-state.tmp
```

**Next Phase Preparation**:
- Create cell_breakdown.md placeholder
- Set up directory structure for cell specifications
- Update CBS application context
- Notify user of successful transition

**Transition Confirmation**:
```bash
echo "✅ Application specification approved!"
echo "📝 Spec: applications/$APP_NAME/.cbs-spec/app_spec.md"
echo "🔄 Phase transition: app_spec → cell_breakdown"
echo "📊 Total iterations: $NEW_ITERATION"
echo ""
echo "Next: Cell breakdown and responsibility assignment"
echo "Command: cbs workflow cell-breakdown"
```

</step>

</process_flow>

## Integration Points

### With Other Workflows
- **Cell Breakdown**: Feeds approved app spec into cell identification
- **Feature Addition**: References app spec for feature context
- **Implementation**: Uses app spec for validation and testing criteria

### With CBS Tools
- **Validation**: Uses CBS validation tools for spec checking
- **Context Management**: Integrates with cbs-app-context
- **Standards Compliance**: Follows CBS standards throughout

### With User Interface
- **CLI Integration**: Works with `cbs` command interface
- **Status Display**: Shows progress in `cbs status`
- **History Tracking**: Maintains iteration history for `cbs workflow history`

This iterative approach ensures the application specification is thoroughly refined before proceeding to cell breakdown, while maintaining complete traceability and rollback capability throughout unlimited iterations.
