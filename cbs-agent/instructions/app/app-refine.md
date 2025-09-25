---
description: Refine and iterate on CBS application specifications
version: 1.0
encoding: UTF-8
---

# Refine CBS Application

## Overview

Iterate on existing CBS application specifications based on user feedback, changing requirements, or new insights. Supports unlimited iterations with complete rollback capability.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="validate_refinement_context">

### Step 1: Validate Refinement Context

Ensure we have an existing application specification to refine.

**Context Validation**:
```bash
# Check workflow state exists
if [ ! -f ".cbs-workflow-state" ]; then
  echo "❌ No application workflow found"
  echo "Create application first: cbs app create <app_name>"
  exit 1
fi

# Get current application and phase
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)
CURRENT_PHASE=$(yq eval '.current_phase' .cbs-workflow-state)

# Check if app spec exists
APP_SPEC_PATH="applications/$CURRENT_APP/.cbs-spec/app_spec.md"
if [ ! -f "$APP_SPEC_PATH" ]; then
  echo "❌ No application specification found"
  echo "Create app spec first: cbs app create"
  exit 1
fi
```

**Phase Compatibility**:
- **app_spec phase**: Direct refinement of current spec
- **Later phases**: Warning about potential impact on cells/implementation
- **Rollback option**: Offer to rollback to app_spec phase if needed

</step>

<step number="2" name="identify_refinement_type">

### Step 2: Identify Refinement Type

Determine what type of changes the user wants to make.

**Refinement Categories**:

**🎯 Scope Changes**:
- Adding or removing core features
- Changing application purpose or target users
- Expanding or reducing functionality

**🔧 Technical Changes**:
- Modifying platform requirements
- Changing integration needs
- Updating performance requirements
- Adjusting technical constraints

**👥 User Experience Changes**:
- Refining user workflows
- Changing target user types
- Updating success criteria
- Modifying user interaction patterns

**🏗️ Architecture Changes**:
- Anticipating different cell breakdown
- Changing message flow patterns
- Modifying complexity estimates

**User Input Processing**:
```bash
echo "What would you like to refine about $CURRENT_APP?"
echo ""
echo "Common refinements:"
echo "1. Add/remove features"
echo "2. Change target users or use cases"  
echo "3. Update technical requirements"
echo "4. Modify user workflows"
echo "5. Adjust success criteria"
echo "6. Other specific changes"
echo ""
echo "Describe what you'd like to change:"
```

</step>

<step number="3" name="analyze_change_impact">

### Step 3: Analyze Change Impact

Assess how the requested changes affect the current specification and downstream phases.

**Impact Analysis Framework**:
```markdown
## Change Impact Analysis

### Requested Changes
- [Change 1]: [Description]
- [Change 2]: [Description]

### Impact Assessment
- **Scope Impact**: [How this affects app scope]
- **Cell Architecture Impact**: [How this affects anticipated cells]
- **Message Flow Impact**: [How this affects communication patterns]
- **Implementation Impact**: [How this affects development effort]

### Affected Sections
- [ ] Application purpose/overview
- [ ] Target users and use cases
- [ ] Core features list
- [ ] User workflows
- [ ] Technical requirements
- [ ] Success criteria
- [ ] Architecture preview

### Downstream Impact
- **Cell Breakdown**: [Will need updates/regeneration]
- **Cell Specs**: [Existing specs may need changes]
- **Implementation**: [May affect ongoing development]
```

**Risk Assessment**:
- **Low Risk**: Minor wording changes, clarifications
- **Medium Risk**: Feature additions, user workflow changes
- **High Risk**: Major scope changes, architecture modifications

</step>

<step number="4" name="create_refinement_iteration">

### Step 4: Create Refinement Iteration

Create a new iteration with the requested changes.

**Iteration Setup**:
```bash
# Create new iteration
CHANGE_DESCRIPTION="$USER_CHANGE_REQUEST"
cbs iterate "$CHANGE_DESCRIPTION"

# This creates:
# - New iteration in workflow state
# - Snapshot of current state
# - Updated iteration history
```

**Specification Updates**:
1. **Load Current Spec**: Read existing `app_spec.md`
2. **Apply Changes**: Modify affected sections based on user input
3. **Update Metadata**: Increment version, update timestamps
4. **Add Iteration Notes**: Document what changed and why
5. **Validate Changes**: Ensure spec remains coherent

**Change Documentation**:
```markdown
## Iteration History
### Iteration [N] - [Date]
- **Changes**: [List of modifications made]
- **Reason**: [Why changes were requested]
- **Impact**: [What sections were affected]
- **Status**: [Pending user approval]
```

</step>

<step number="5" name="validate_refined_specification">

### Step 5: Validate Refined Specification

Ensure the refined specification maintains quality and CBS compliance.

**Validation Checks**:
- **Consistency**: Changes don't conflict with other sections
- **Completeness**: All required sections still present and complete
- **CBS Compliance**: Still follows cell-based architecture principles
- **Feasibility**: Changes are technically achievable
- **Clarity**: Specification remains clear and unambiguous

**CBS-Specific Validation**:
- Features can still be decomposed into cells
- Message flow patterns remain viable
- Cell isolation principles are maintained
- No features require direct cell-to-cell communication

**Quality Metrics**:
```markdown
## Refinement Validation Report

### ✅ Quality Checks
- [x] Specification remains complete
- [x] Changes are internally consistent
- [x] CBS architecture principles maintained
- [x] Technical requirements are achievable

### ⚠️ Considerations
- [Consideration 1]: [Description and recommendation]
- [Consideration 2]: [Description and recommendation]

### 📊 Impact Summary
- **Complexity Change**: [Increased/Decreased/Same]
- **Cell Count Estimate**: [Previous] → [New estimate]
- **Development Effort**: [Impact on timeline]
```

</step>

<step number="6" name="present_refined_specification">

### Step 6: Present Refined Specification

Show the updated specification to the user for approval.

**Presentation Format**:
```markdown
## 📝 Application Specification Refined

**Application**: $APP_NAME
**Iteration**: [N]
**Phase**: app_spec

### 🔄 Changes Made
[Detailed summary of what was changed]

### 📊 Impact Summary
- **Features**: [Previous count] → [New count]
- **Complexity**: [Assessment of complexity change]
- **Architecture**: [Impact on anticipated cell structure]

### 🎯 Updated Specification Highlights
- **Purpose**: [Updated purpose if changed]
- **Key Features**: [Updated feature list]
- **Success Criteria**: [Updated criteria]

### 📄 Full Specification
Location: `applications/$APP_NAME/.cbs-spec/app_spec.md`

### ✅ Validation Status
[Summary of validation results]

### 🔄 Your Options
1. **Approve**: Accept changes and proceed
2. **Further Refine**: Make additional changes
3. **Rollback**: Return to previous iteration

**What would you like to do?**
```

</step>

<step number="7" name="handle_approval_or_iteration">

### Step 7: Handle Approval or Further Iteration

Process user decision and either proceed or continue iterating.

**User Response Handling**:

**Approval Path**:
```bash
if [ "$USER_RESPONSE" = "approve" ]; then
  # Update workflow state
  yq eval '.phases.app_spec.status = "completed"' .cbs-workflow-state
  
  echo "✅ Application specification approved!"
  echo "📝 Spec: applications/$APP_NAME/.cbs-spec/app_spec.md"  
  echo "🔄 Ready for cell breakdown"
  echo ""
  echo "Next step: cbs app breakdown"
fi
```

**Further Refinement Path**:
```bash
if [[ "$USER_RESPONSE" == "refine:"* ]]; then
  # Extract refinement details
  REFINEMENT_REQUEST="${USER_RESPONSE#refine: }"
  
  echo "🔄 Starting new refinement iteration..."
  # Loop back to step 2 with new requirements
fi
```

**Rollback Path**:
```bash
if [[ "$USER_RESPONSE" == "rollback"* ]]; then
  # Extract iteration number if specified
  ROLLBACK_TARGET="${USER_RESPONSE#rollback }"
  
  echo "🔄 Rolling back to iteration $ROLLBACK_TARGET..."
  cbs workflow rollback "$ROLLBACK_TARGET"
fi
```

**Unlimited Iteration Support**:
- No artificial limits on refinement cycles
- Each iteration creates snapshot for safety
- Complete change history maintained
- User controls when to proceed or abandon

</step>

</process_flow>

## Command Integration

### **CLI Command**: `cbs app refine`
```bash
# Refine current application specification
cbs app refine

# Refine with specific change description
cbs app refine "Add real-time messaging features"

# Refine specific section
cbs app refine --section features "Add push notifications"
```

### **Workflow Integration**:
- Works in any phase (with appropriate warnings)
- Creates proper iterations and snapshots
- Updates workflow state automatically
- Integrates with rollback system

### **Next Steps After Approval**:
- **Cell Breakdown**: `cbs app breakdown` - Break app into cells
- **Feature Addition**: `cbs feature add` - Add new features
- **Implementation**: Skip to `cbs cell build` if cells already designed

This instruction provides intuitive, powerful application refinement with unlimited iterations and proper CBS compliance.
