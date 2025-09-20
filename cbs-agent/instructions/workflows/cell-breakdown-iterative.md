---
description: Iterative Cell Breakdown and Responsibility Assignment for CBS Applications
version: 1.0
encoding: UTF-8
---

# Iterative Cell Breakdown

## Overview

Break down approved application specifications into individual cells with clear responsibilities, message contracts, and communication patterns through unlimited iterations.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="validate_prerequisites">

### Step 1: Validate Prerequisites

Ensure the application specification is complete and approved before proceeding with cell breakdown.

**Prerequisite Checks**:
```bash
# Check workflow state
CURRENT_PHASE=$(yq eval '.current_phase' .cbs-workflow-state)
APP_SPEC_STATUS=$(yq eval '.phases.app_spec.status' .cbs-workflow-state)
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)

# Validate prerequisites
if [ "$CURRENT_PHASE" != "cell_breakdown" ]; then
  echo "⚠️ Not in cell_breakdown phase. Current: $CURRENT_PHASE"
  echo "Use: cbs workflow set-phase cell_breakdown"
  exit 1
fi

if [ "$APP_SPEC_STATUS" != "completed" ]; then
  echo "❌ Application spec not completed. Status: $APP_SPEC_STATUS"
  echo "Complete app spec first: cbs workflow app-spec"
  exit 1
fi

# Check app spec file exists
APP_SPEC_PATH="applications/$CURRENT_APP/ai/app_spec.md"
if [ ! -f "$APP_SPEC_PATH" ]; then
  echo "❌ Application spec file not found: $APP_SPEC_PATH"
  exit 1
fi
```

**Spec Analysis**:
- Extract core features from approved app spec
- Identify user interaction patterns
- Analyze data flow requirements
- Note integration points with external systems

</step>

<step number="2" name="analyze_application_features">

### Step 2: Analyze Application Features

Parse the approved application specification to understand feature requirements and identify potential cell boundaries.

**Feature Extraction**:
```bash
# Extract features from app spec
grep -A 5 "### Core Features" "$APP_SPEC_PATH" | grep "^[0-9]" > features.tmp

# Extract technical requirements  
grep -A 10 "### Technical Requirements" "$APP_SPEC_PATH" > tech_requirements.tmp

# Extract success criteria
grep -A 10 "### Success Criteria" "$APP_SPEC_PATH" > success_criteria.tmp
```

**Feature Analysis Framework**:
```markdown
## Feature Analysis for Cell Breakdown

### Feature: ${FEATURE_NAME}
- **User Interaction**: [How users interact with this feature]
- **Data Requirements**: [What data is needed/produced]
- **Business Logic**: [What processing/transformation occurs]
- **External Dependencies**: [APIs, services, or systems needed]
- **UI Components**: [User interface elements required]

### Cell Boundary Analysis
- **Single Responsibility**: Can this be handled by one cell?
- **Data Flow**: What messages need to be exchanged?
- **Isolation**: Can this operate independently?
- **Reusability**: Could this cell be used in other applications?
```

**Automated Analysis**:
- Identify CRUD operations (Create, Read, Update, Delete)
- Map user workflows to potential cell chains
- Identify shared data and communication needs
- Flag complex features that may need multiple cells

</step>

<step number="3" name="identify_cell_categories">

### Step 3: Identify Cell Categories and Responsibilities

Map application features to CBS cell categories and define clear responsibilities.

**CBS Cell Categories**:
- **UI Cells**: User interface components and interactions
- **Logic Cells**: Business logic, data processing, and transformations
- **Integration Cells**: External service connections and API management
- **Storage Cells**: Data persistence, caching, and retrieval
- **IO Cells**: Input/output operations (files, network, etc.)

**Cell Identification Process**:
```markdown
## Cell Identification Matrix

| Feature | UI Needs | Logic Needs | Storage Needs | Integration Needs | IO Needs |
|---------|----------|-------------|---------------|-------------------|----------|
| User Auth | Login UI | Auth Logic | User Storage | OAuth Service | Session Files |
| Data Display | List UI | Filter Logic | Data Cache | API Client | Export Files |
| Notifications | Alert UI | Notify Logic | Message Queue | Email Service | Log Files |

## Proposed Cells

### UI Category
- **${app}_main_ui** - Primary user interface and navigation
- **${app}_auth_ui** - Authentication forms and user management UI
- **${app}_data_ui** - Data display and interaction components

### Logic Category  
- **${app}_auth_logic** - Authentication and authorization processing
- **${app}_data_processor** - Core business logic and data transformation
- **${app}_validation** - Input validation and business rule enforcement

### Integration Category
- **${app}_api_client** - External API communication and management
- **${app}_notification_service** - Email, SMS, and push notification handling

### Storage Category
- **${app}_user_store** - User data persistence and management
- **${app}_app_data_store** - Application data storage and retrieval
- **${app}_cache_manager** - Caching strategy and temporary storage
```

</step>

<step number="4" name="design_message_contracts">

### Step 4: Design Message Contracts and Communication Patterns

Define how cells will communicate through the CBS bus with typed messages.

**Message Contract Design**:
```markdown
## Message Flow Design

### Authentication Flow
1. **UI → Auth Logic**: `cbs.${app}_auth_logic.authenticate`
   - Payload: `{username: string, password: string}`
   - Response: `{success: boolean, token: string, error?: string}`

2. **Auth Logic → User Store**: `cbs.${app}_user_store.get_user`
   - Payload: `{username: string}`
   - Response: `{user: UserData, exists: boolean}`

3. **Auth Logic → UI**: `cbs.${app}_main_ui.auth_result`
   - Payload: `{authenticated: boolean, user?: UserData, error?: string}`

### Data Processing Flow
1. **UI → Data Processor**: `cbs.${app}_data_processor.process_request`
   - Payload: `{action: string, data: any, filters?: FilterData}`
   - Response: `{result: any, success: boolean, error?: string}`

2. **Data Processor → Storage**: `cbs.${app}_app_data_store.query`
   - Payload: `{query: QueryData, filters: FilterData}`
   - Response: `{data: DataResult[], count: number}`
```

**Message Schema Standards**:
- All messages use CBS envelope format
- Schema versioning: `${service}.${verb}.v1`
- Correlation IDs for request/response tracking
- Standardized error message format
- Timeout handling for all async operations

**Communication Patterns**:
- **Request-Response**: Synchronous operations with expected responses
- **Publish-Subscribe**: Event notifications and state changes  
- **Fire-and-Forget**: Logging and non-critical notifications
- **Chain Processing**: Multi-step workflows through cell sequences

</step>

<step number="5" name="validate_cell_isolation">

### Step 5: Validate Cell Isolation and Dependencies

Ensure each cell maintains proper isolation while defining necessary dependencies.

**Isolation Validation**:
```markdown
## Cell Isolation Analysis

### ${CELL_NAME} Cell
- **Single Responsibility**: ✅ Handles only ${RESPONSIBILITY}
- **Bus-Only Communication**: ✅ No direct cell references
- **State Independence**: ✅ Maintains own state only
- **Testability**: ✅ Can be tested in isolation
- **Reusability**: ✅ Could be used in other applications

### Dependencies
- **Hard Dependencies**: Cells that must respond for this cell to function
- **Soft Dependencies**: Cells that enhance functionality but aren't required
- **Circular Dependencies**: ❌ None detected (verified)

### Message Contracts
- **Subscribes To**: [List of subjects this cell listens to]
- **Publishes To**: [List of subjects this cell sends to]  
- **Queue Groups**: [Queue group membership for load balancing]
```

**Dependency Graph Validation**:
- Create directed acyclic graph (DAG) of cell dependencies
- Identify potential circular dependencies
- Validate load order for cell initialization
- Ensure no cell has too many dependencies (complexity warning)

**CBS Compliance Check**:
- No direct imports between cells
- All communication through typed bus messages
- Each cell has single, clear responsibility
- Cells can be developed and tested independently

</step>

<step number="6" name="create_cell_breakdown_document">

### Step 6: Create Cell Breakdown Document

Generate comprehensive documentation of the cell breakdown analysis and design.

**Cell Breakdown Document Structure**:
```markdown
# Cell Breakdown - ${APP_NAME}

## Overview
- **Application**: ${APP_NAME}
- **Total Cells**: ${CELL_COUNT}
- **Breakdown Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Iteration**: ${ITERATION_NUMBER}

## Cell Architecture Summary

### Cell Distribution
- **UI Cells**: ${UI_COUNT} cells
- **Logic Cells**: ${LOGIC_COUNT} cells  
- **Integration Cells**: ${INTEGRATION_COUNT} cells
- **Storage Cells**: ${STORAGE_COUNT} cells
- **IO Cells**: ${IO_COUNT} cells

### Communication Overview
- **Total Message Types**: ${MESSAGE_COUNT}
- **Request-Response Patterns**: ${REQUEST_RESPONSE_COUNT}
- **Event Notifications**: ${EVENT_COUNT}
- **Data Flows**: ${DATA_FLOW_COUNT}

## Detailed Cell Specifications

### UI Cells
${UI_CELLS_DETAILS}

### Logic Cells  
${LOGIC_CELLS_DETAILS}

### Integration Cells
${INTEGRATION_CELLS_DETAILS}

### Storage Cells
${STORAGE_CELLS_DETAILS}

## Message Flow Diagrams

### Primary User Workflows
${WORKFLOW_DIAGRAMS}

### Data Processing Flows
${DATA_FLOW_DIAGRAMS}

### Error Handling Flows
${ERROR_FLOW_DIAGRAMS}

## Implementation Priority

### Phase 1: Core Infrastructure
${PHASE_1_CELLS}

### Phase 2: Business Logic
${PHASE_2_CELLS}

### Phase 3: User Interface
${PHASE_3_CELLS}

### Phase 4: Integrations
${PHASE_4_CELLS}

## Validation Results

### Isolation Compliance
${ISOLATION_VALIDATION_RESULTS}

### Message Contract Validation
${CONTRACT_VALIDATION_RESULTS}

### Dependency Analysis
${DEPENDENCY_ANALYSIS_RESULTS}

## Iteration History
${ITERATION_HISTORY}
```

**Document Generation**:
- Auto-generate cell details from analysis
- Create ASCII diagrams for message flows
- Include validation results and warnings
- Add implementation recommendations

</step>

<step number="7" name="update_workflow_state">

### Step 7: Update Workflow State

Update the workflow state to reflect the cell breakdown iteration and progress.

**State Update Process**:
```bash
# Update workflow state with cell breakdown progress
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ITERATION=$(yq eval '.phases.cell_breakdown.iteration' .cbs-workflow-state)
NEW_ITERATION=$((ITERATION + 1))

# Create breakdown summary for state
BREAKDOWN_SUMMARY="Identified $CELL_COUNT cells across $CATEGORY_COUNT categories"

# Update state file
yq eval "
  .last_updated = \"$TIMESTAMP\" |
  .iteration_count = $(($(yq eval '.iteration_count' .cbs-workflow-state) + 1)) |
  .phases.cell_breakdown.iteration = $NEW_ITERATION |
  .phases.cell_breakdown.status = \"in_progress\" |
  .phases.cell_breakdown.last_modified = \"$TIMESTAMP\" |
  .phases.cell_breakdown.breakdown_path = \"applications/$CURRENT_APP/ai/cell_breakdown.md\" |
  .iterations += [{
    \"id\": $NEW_ITERATION,
    \"phase\": \"cell_breakdown\",
    \"timestamp\": \"$TIMESTAMP\",
    \"description\": \"$BREAKDOWN_SUMMARY\",
    \"changes\": [\"Created cell breakdown document\", \"Defined message contracts\"]
  }]
" .cbs-workflow-state > .cbs-workflow-state.tmp

mv .cbs-workflow-state.tmp .cbs-workflow-state
```

**Snapshot Creation**:
- Create snapshot including cell breakdown document
- Store workflow state and all related files
- Enable rollback to this iteration if needed

</step>

<step number="8" name="present_for_review">

### Step 8: Present Cell Breakdown for Review

Present the cell breakdown to the user for review and feedback.

**Presentation Format**:
```markdown
## 🧬 Cell Breakdown Ready for Review

**Application**: ${APP_NAME}
**Iteration**: ${NEW_ITERATION}
**Phase**: cell_breakdown

### 📊 Breakdown Summary
- **Total Cells**: ${CELL_COUNT}
- **Message Types**: ${MESSAGE_COUNT}
- **Implementation Phases**: ${PHASE_COUNT}

### 🎯 Cell Distribution
- UI: ${UI_COUNT} cells
- Logic: ${LOGIC_COUNT} cells  
- Integration: ${INTEGRATION_COUNT} cells
- Storage: ${STORAGE_COUNT} cells

### 📋 Key Cells Identified
${KEY_CELLS_SUMMARY}

### 🔄 Message Flow Highlights
${MESSAGE_FLOW_HIGHLIGHTS}

### ✅ Validation Status
- Cell Isolation: ${ISOLATION_STATUS}
- Message Contracts: ${CONTRACT_STATUS}
- Dependencies: ${DEPENDENCY_STATUS}

### 📄 Full Breakdown
Location: `applications/${APP_NAME}/ai/cell_breakdown.md`

### 🔄 Review Options
1. **Approve**: Proceed to individual cell specifications
2. **Modify**: Request changes to cell responsibilities or communication
3. **Restructure**: Major changes to cell breakdown approach

### 💬 User Decision Required
Please review the cell breakdown and choose:
- Type "approve" to proceed to cell specifications
- Type "modify: [description]" for specific changes
- Type "restructure: [description]" for major reorganization
```

</step>

<step number="9" name="handle_iteration_feedback">

### Step 9: Handle Iteration Feedback

Process user feedback and iterate on the cell breakdown until approved.

**Feedback Types and Handling**:

**Cell Responsibility Changes**:
- User wants different cell boundaries
- Merge cells that are too granular
- Split cells that are too complex
- Reassign responsibilities between cells

**Message Contract Modifications**:
- Change message schemas or patterns
- Add new communication paths
- Remove unnecessary message flows
- Optimize message routing

**Architecture Adjustments**:
- Change cell categories or distribution
- Modify implementation phases
- Adjust dependency relationships
- Update isolation boundaries

**Iteration Process**:
```bash
# Handle user feedback iteration
case "$USER_FEEDBACK" in
  "approve")
    # Transition to next phase
    transition_to_cell_specs
    ;;
  "modify:"*)
    # Extract modification details
    MODIFICATION="${USER_FEEDBACK#modify: }"
    create_modification_iteration "$MODIFICATION"
    ;;
  "restructure:"*)
    # Extract restructure details  
    RESTRUCTURE="${USER_FEEDBACK#restructure: }"
    create_major_revision_iteration "$RESTRUCTURE"
    ;;
esac
```

**Unlimited Iteration Support**:
- No limit on number of iterations
- Each iteration creates snapshot for rollback
- Maintain complete change history
- User controls when to proceed or restart

</step>

<step number="10" name="transition_to_cell_specs">

### Step 10: Transition to Cell Specifications (On Approval)

When user approves the cell breakdown, transition to individual cell specification creation.

**Approval Actions**:
```bash
# Mark cell_breakdown as completed
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

yq eval "
  .current_phase = \"cell_specs\" |
  .phases.cell_breakdown.status = \"completed\" |
  .phases.cell_breakdown.completed_at = \"$TIMESTAMP\" |
  .phases.cell_specs.status = \"in_progress\" |
  .phases.cell_specs.started_at = \"$TIMESTAMP\"
" .cbs-workflow-state > .cbs-workflow-state.tmp

mv .cbs-workflow-state.tmp .cbs-workflow-state
```

**Cell Directory Setup**:
```bash
# Create directory structure for each identified cell
for cell in $IDENTIFIED_CELLS; do
  CELL_DIR="applications/$CURRENT_APP/cells/$cell"
  mkdir -p "$CELL_DIR/ai"
  mkdir -p "$CELL_DIR/lib" 
  mkdir -p "$CELL_DIR/test"
  
  # Create placeholder spec file
  echo "# $cell Cell Specification" > "$CELL_DIR/ai/spec.md"
  echo "## Status: Pending creation" >> "$CELL_DIR/ai/spec.md"
done
```

**Next Phase Preparation**:
- Initialize cell specification templates
- Set up individual cell contexts
- Prepare for cell-by-cell development
- Update CBS application context

**Transition Confirmation**:
```bash
echo "✅ Cell breakdown approved!"
echo "📁 Breakdown: applications/$APP_NAME/ai/cell_breakdown.md"
echo "🧬 Identified: $CELL_COUNT cells"
echo "🔄 Phase transition: cell_breakdown → cell_specs"
echo ""
echo "Next: Individual cell specification creation"
echo "Command: cbs workflow cell-specs"
```

</step>

</process_flow>

## Integration with Development Flow

### Rollback Support
- Complete snapshot system for all iterations
- Rollback to any previous cell breakdown
- Preserve user decisions and reasoning
- Maintain iteration history and context

### Quality Assurance
- Automated validation of CBS principles
- Message contract consistency checking
- Dependency cycle detection
- Isolation compliance verification

### User Experience
- Clear progress indicators throughout process
- Comprehensive feedback on each iteration
- Easy rollback and modification capabilities
- Integration with overall workflow status

This iterative cell breakdown process ensures that the application architecture is thoroughly planned and validated before moving to individual cell implementation, while supporting unlimited refinement cycles.
