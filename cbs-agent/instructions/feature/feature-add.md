---
description: Add new features to existing CBS applications through cell modification or creation
version: 1.0
encoding: UTF-8
---

# Add Feature to CBS Application

## Overview

Add new features to existing CBS applications by analyzing feature requirements, determining cell impact, and implementing changes while maintaining cell isolation and bus-only communication.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="validate_application_context">

### Step 1: Validate Application Context

Ensure we have an existing CBS application to add features to.

**Context Validation**:
```bash
# Check workflow state exists
if [ ! -f ".cbs-workflow-state" ]; then
  echo "❌ No application workflow found"
  echo "Create application first: cbs app create <app_name>"
  exit 1
fi

# Get current application
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)
CURRENT_PHASE=$(yq eval '.current_phase' .cbs-workflow-state)

# Check application exists and has cells
APP_DIR="applications/$CURRENT_APP"
if [ ! -d "$APP_DIR" ]; then
  echo "❌ Application directory not found: $APP_DIR"
  exit 1
fi

CELLS_DIR="$APP_DIR/cells"
if [ ! -d "$CELLS_DIR" ] || [ -z "$(ls -A "$CELLS_DIR" 2>/dev/null)" ]; then
  echo "⚠️  No existing cells found in $CELLS_DIR"
  echo "Consider: cbs app breakdown (to design cells first)"
fi
```

**Application State Analysis**:
```bash
# Analyze current application state
EXISTING_CELLS=$(ls "$CELLS_DIR" 2>/dev/null | wc -l)
IMPLEMENTED_CELLS=$(find "$CELLS_DIR" -name "*.dart" -o -name "*.rs" -o -name "*.py" | wc -l)

echo "📊 Current Application State:"
echo "  Application: $CURRENT_APP"
echo "  Phase: $CURRENT_PHASE"
echo "  Existing Cells: $EXISTING_CELLS"
echo "  Implemented Cells: $IMPLEMENTED_CELLS"
```

</step>

<step number="2" name="gather_feature_requirements">

### Step 2: Gather Feature Requirements

Collect detailed requirements for the new feature.

**Feature Analysis Questions**:
1. **Feature Description**: What does this feature do? (1-2 sentences)
2. **User Value**: How does this benefit users?
3. **User Interactions**: How do users interact with this feature?
4. **Data Requirements**: What data does it need/create/modify?
5. **External Dependencies**: Does it need external services/APIs?
6. **Integration Points**: How does it connect with existing features?

**CBS-Specific Analysis**:
- **Cell Impact**: Which existing cells might be affected?
- **New Cells Needed**: Does this require entirely new cells?
- **Message Flows**: What new bus communications are needed?
- **Isolation Considerations**: How to maintain cell boundaries?

**Feature Specification Template**:
```markdown
# Feature Specification - $FEATURE_NAME

## Overview
- **Feature**: $FEATURE_NAME
- **Application**: $CURRENT_APP
- **User Value**: [How this benefits users]
- **Priority**: [High/Medium/Low]

## Requirements
### User Story
As a [user type], I want to [action], so that [benefit].

### Functional Requirements
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

### Technical Requirements
- **Data Needs**: [What data is required]
- **External Services**: [APIs or services needed]
- **Performance**: [Response time, throughput requirements]
- **Security**: [Authentication, authorization needs]

## CBS Architecture Impact
### Existing Cells Affected
- **[Cell Name]**: [How it will be modified]
- **[Cell Name]**: [What changes are needed]

### New Cells Required
- **[New Cell Name]** ([category]): [Purpose and responsibility]
- **[New Cell Name]** ([category]): [Purpose and responsibility]

### Message Flow Design
[ASCII diagram or description of new message flows]
```

</step>

<step number="3" name="analyze_cell_impact">

### Step 3: Analyze Cell Impact

Determine how the feature affects existing cells and what new cells are needed.

**Impact Analysis Process**:

**Existing Cell Analysis**:
```bash
# For each existing cell, analyze feature impact
for cell_dir in "$CELLS_DIR"/*; do
  if [ -d "$cell_dir" ]; then
    cell_name=$(basename "$cell_dir")
    cell_spec="$cell_dir/ai/spec.md"
    
    if [ -f "$cell_spec" ]; then
      # Analyze if this cell needs modifications for the feature
      cell_purpose=$(grep "Purpose" "$cell_spec" | cut -d: -f2- | xargs)
      cell_category=$(grep "Category" "$cell_spec" | cut -d: -f2 | xargs)
      
      echo "🧬 Analyzing cell: $cell_name ($cell_category)"
      echo "   Purpose: $cell_purpose"
      echo "   Feature impact: [To be determined]"
    fi
  fi
done
```

**Cell Modification Types**:
- **Interface Extension**: Add new message handlers
- **Logic Enhancement**: Extend existing functionality  
- **New Responsibilities**: Add related functionality
- **Message Contract Updates**: New publish/subscribe subjects

**New Cell Identification**:
- **Feature-Specific Logic**: Business logic unique to this feature
- **New Integrations**: External services for this feature
- **New UI Components**: User interface elements
- **New Storage Requirements**: Data persistence for feature

**Cell Impact Matrix**:
```markdown
## Cell Impact Matrix

| Existing Cell | Impact Type | Changes Needed | New Messages | Effort |
|---------------|-------------|----------------|--------------|---------|
| user_auth | Interface | Add feature permissions | cbs.auth.check_feature | S |
| main_ui | Logic | Add feature UI components | cbs.ui.render_feature | M |
| data_store | Interface | Add feature data storage | cbs.store.feature_data | L |

## New Cells Required

| New Cell | Category | Purpose | Key Messages | Effort |
|----------|----------|---------|--------------|---------|
| feature_processor | logic | Process feature-specific logic | cbs.feature.process | M |
| feature_notifier | integration | Send feature notifications | cbs.notify.feature | S |
```

</step>

<step number="4" name="design_message_contracts">

### Step 4: Design Message Contracts

Design the bus communication patterns for the new feature.

**Message Flow Design**:
```markdown
## Message Flow Design for $FEATURE_NAME

### Primary Feature Flow
1. **User Action** → UI Cell
   - Subject: `cbs.main_ui.feature_request`
   - Payload: `{action: string, params: object}`

2. **UI Cell** → Feature Logic Cell
   - Subject: `cbs.feature_processor.process`
   - Payload: `{request: FeatureRequest, user_id: string}`

3. **Feature Logic** → Data Storage
   - Subject: `cbs.data_store.save_feature_data`
   - Payload: `{data: FeatureData, user_id: string}`

4. **Feature Logic** → Notification Cell
   - Subject: `cbs.feature_notifier.send`
   - Payload: `{type: string, recipient: string, data: object}`

### Error Handling Flow
1. **Any Cell** → Error Handler
   - Subject: `cbs.error_handler.feature_error`
   - Payload: `{error: ErrorDetails, context: string}`

### Event Notifications
1. **Feature Complete** → All Interested Cells
   - Subject: `cbs.events.feature_completed`
   - Payload: `{feature: string, result: object, user_id: string}`
```

**Message Schema Definitions**:
```typescript
// New message schemas for feature
interface FeatureRequest {
  action: string;
  parameters: Record<string, any>;
  timestamp: string;
}

interface FeatureData {
  id: string;
  type: string;
  content: Record<string, any>;
  created_at: string;
}

interface FeatureNotification {
  type: 'success' | 'error' | 'info';
  recipient: string;
  message: string;
  data?: Record<string, any>;
}
```

</step>

<step number="5" name="create_implementation_plan">

### Step 5: Create Implementation Plan

Generate a plan for implementing the feature across affected cells.

**Implementation Strategy**:

**Phase 1: Cell Modifications**
```markdown
## Implementation Plan - $FEATURE_NAME

### Phase 1: Update Existing Cells
- [ ] **$CELL_1**: [Specific changes needed]
  - Update message handlers for new subjects
  - Extend business logic for feature support
  - Add new message publishing capabilities
  - Update tests for new functionality

- [ ] **$CELL_2**: [Specific changes needed]
  - Modify UI components for feature
  - Add new user interaction handlers
  - Update state management for feature data
  - Add integration tests for new flows

### Phase 2: Create New Cells
- [ ] **$NEW_CELL_1** ($CATEGORY): [Purpose]
  - Design cell specification
  - Implement core logic
  - Add message handling
  - Create comprehensive tests

### Phase 3: Integration Testing
- [ ] **Message Flow Testing**: Test complete feature workflow
- [ ] **Error Handling**: Test error scenarios and recovery
- [ ] **Performance Testing**: Validate feature performance
- [ ] **Isolation Validation**: Ensure cell boundaries maintained
```

**Task Generation**:
- Generate specific tasks for each cell modification
- Create tasks for new cell implementation
- Add integration testing tasks
- Include validation and rollback tasks

</step>

<step number="6" name="update_workflow_state">

### Step 6: Update Workflow State

Update the workflow state to track the feature addition.

**Workflow State Updates**:
```bash
# Add feature to workflow state
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ITERATION_COUNT=$(yq eval '.iteration_count' .cbs-workflow-state)
NEW_ITERATION=$((ITERATION_COUNT + 1))

yq eval "
  .current_phase = \"feature_addition\" |
  .iteration_count = $NEW_ITERATION |
  .phases.feature_addition.status = \"in_progress\" |
  .phases.feature_addition.features += [{
    \"name\": \"$FEATURE_NAME\",
    \"status\": \"spec_complete\",
    \"affected_cells\": $AFFECTED_CELLS_JSON,
    \"new_cells\": $NEW_CELLS_JSON,
    \"iteration\": 1
  }] |
  .iterations += [{
    \"id\": $NEW_ITERATION,
    \"phase\": \"feature_addition\",
    \"timestamp\": \"$TIMESTAMP\",
    \"description\": \"Added feature: $FEATURE_NAME\",
    \"changes\": [\"Created feature specification\", \"Updated cell contracts\"]
  }]
" .cbs-workflow-state > .cbs-workflow-state.tmp

mv .cbs-workflow-state.tmp .cbs-workflow-state
```

**Snapshot Creation**:
- Create snapshot before implementation begins
- Include all modified cell specifications
- Store feature specification document
- Enable rollback to pre-feature state

</step>

<step number="7" name="present_implementation_plan">

### Step 7: Present Implementation Plan

Show the complete feature implementation plan for user approval.

**Implementation Plan Presentation**:
```markdown
## 🚀 Feature Implementation Plan Ready

**Feature**: $FEATURE_NAME
**Application**: $CURRENT_APP
**Estimated Effort**: [S/M/L based on analysis]

### 📊 Implementation Summary
- **Cells to Modify**: $MODIFIED_CELL_COUNT existing cells
- **New Cells**: $NEW_CELL_COUNT new cells to create
- **Message Contracts**: $NEW_MESSAGE_COUNT new message types
- **Integration Points**: $INTEGRATION_COUNT external connections

### 🧬 Cell Changes
[Detailed breakdown of what changes to each cell]

### 📨 New Message Flows
[Summary of new bus communication patterns]

### 🔄 Implementation Options
1. **Start Implementation**: Begin building the feature
2. **Refine Feature**: Make changes to feature specification
3. **Simplify Approach**: Reduce scope or complexity
4. **Cancel Feature**: Remove feature from plan

### 💬 Ready to Implement?
- Type "implement" to start building the feature
- Type "refine: [changes]" to modify the feature plan
- Type "simplify" to reduce scope
- Type "cancel" to remove this feature
```

</step>

</process_flow>

## Integration Points

### **With Application Workflow**:
- Integrates with existing application development phases
- Maintains application-level workflow state
- Preserves existing cell implementations

### **With Cell Development**:
- Updates existing cell specifications
- Creates new cell specifications as needed
- Maintains cell isolation throughout feature addition

### **With Implementation**:
- Generates implementation tasks for feature
- Coordinates multi-cell implementation
- Validates feature integration

This instruction provides a complete, intuitive workflow for adding features to CBS applications while maintaining proper cell architecture and unlimited iteration support.
