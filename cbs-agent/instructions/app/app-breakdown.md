---
description: Break down approved CBS application into individual cells with message contracts
version: 1.0
encoding: UTF-8
---

# Break Down CBS Application into Cells

## Overview

Analyze an approved CBS application specification and break it down into individual cells with clear responsibilities, message contracts, and communication patterns.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="validate_app_spec_approved">

### Step 1: Validate Application Specification Approved

Ensure we have an approved application specification to break down.

**Prerequisites Check**:
```bash
# Check workflow state
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)
APP_SPEC_STATUS=$(yq eval '.phases.app_spec.status' .cbs-workflow-state)

if [ "$APP_SPEC_STATUS" != "completed" ]; then
  echo "❌ Application specification not approved"
  echo "Current status: $APP_SPEC_STATUS"
  echo ""
  echo "Complete app spec first:"
  echo "  cbs app create (if new)"
  echo "  cbs app refine (if needs changes)"
  exit 1
fi

# Load application specification
APP_SPEC_PATH="applications/$CURRENT_APP/ai/app_spec.md"
if [ ! -f "$APP_SPEC_PATH" ]; then
  echo "❌ Application specification not found: $APP_SPEC_PATH"
  exit 1
fi
```

**Application Analysis**:
- Extract core features from app specification
- Identify user workflows and interaction patterns
- Note technical requirements and constraints
- Understand success criteria and performance needs

</step>

<step number="2" name="analyze_features_for_cell_boundaries">

### Step 2: Analyze Features for Cell Boundaries

Map application features to potential cell responsibilities using CBS principles.

**Feature-to-Cell Analysis**:
```bash
# Extract features from app spec
FEATURES=$(grep -A 20 "## Core Features" "$APP_SPEC_PATH" | grep "^[0-9]" | sed 's/^[0-9]*\. \*\*//' | sed 's/\*\* - /: /')

echo "🔍 Analyzing features for cell breakdown:"
echo "$FEATURES"
```

**Cell Boundary Analysis Framework**:
```markdown
## Feature Analysis for Cell Boundaries

### Feature: [Feature Name]
- **User Interaction**: [How users interact with this feature]
- **Data Flow**: [What data flows in/out]
- **Business Logic**: [What processing/transformation occurs]
- **External Dependencies**: [APIs, services, databases needed]
- **UI Requirements**: [User interface elements needed]

### CBS Cell Mapping
- **UI Responsibility**: [What UI components are needed]
- **Logic Responsibility**: [What business logic is required]
- **Integration Responsibility**: [What external connections needed]
- **Storage Responsibility**: [What data persistence required]
- **IO Responsibility**: [What input/output operations needed]

### Single Responsibility Test
- **Can this be one cell?**: [Yes/No + reasoning]
- **Natural boundaries**: [Where to split if too complex]
- **Reusability potential**: [Could this cell be reused elsewhere?]
```

**Automated Cell Identification**:
- **CRUD Operations**: Identify Create, Read, Update, Delete patterns
- **User Workflows**: Map user journeys to cell chains
- **Data Entities**: Map data types to storage responsibilities
- **External Services**: Map integrations to integration cells

</step>

<step number="3" name="design_cell_architecture">

### Step 3: Design Cell Architecture

Create the overall cell architecture with clear responsibilities and communication patterns.

**Cell Architecture Design**:
```markdown
# Cell Architecture - $CURRENT_APP

## Overview
- **Total Cells**: [N] cells across [N] categories
- **Architecture Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Based on**: Application specification v[X]
- **Structure**: Hierarchical organization by domain and category

## Hierarchical Cell Breakdown

### Core Domain (core/)
#### UI Cells (core/ui/)
- **main_shell** - Application shell and global navigation
  - **Path**: `core/ui/main_shell/`
  - **Purpose**: Handle app-wide UI structure and navigation
  - **Subscribes**: `cbs.main_shell.render`, `cbs.main_shell.navigate`
  - **Publishes**: `cbs.navigation.request`, `cbs.ui.global_state`

- **error_display** - Global error handling UI
  - **Path**: `core/ui/error_display/`
  - **Purpose**: Display system-wide errors and notifications
  - **Subscribes**: `cbs.error_display.show`, `cbs.error_display.clear`
  - **Publishes**: `cbs.error.acknowledged`, `cbs.ui.error_state`

#### Logic Cells (core/logic/)
- **app_controller** - Main application controller
  - **Path**: `core/logic/app_controller/`
  - **Purpose**: Coordinate app-wide logic and state management
  - **Subscribes**: `cbs.app_controller.init`, `cbs.app_controller.shutdown`
  - **Publishes**: `cbs.app.ready`, `cbs.app.state_change`

### Feature Domains (features/)
#### Authentication Domain (features/authentication/)
##### UI Cells (features/authentication/ui/)
- **login_form** - User login interface
  - **Path**: `features/authentication/ui/login_form/`
  - **Purpose**: Handle user login interactions
  - **Subscribes**: `cbs.login_form.render`, `cbs.login_form.submit`
  - **Publishes**: `cbs.auth.attempt`, `cbs.ui.login_state`

##### Logic Cells (features/authentication/logic/)
- **auth_processor** - Authentication business logic
  - **Path**: `features/authentication/logic/auth_processor/`
  - **Purpose**: Process authentication requests and manage sessions
  - **Subscribes**: `cbs.auth_processor.authenticate`, `cbs.auth_processor.validate`
  - **Publishes**: `cbs.auth.result`, `cbs.session.created`

##### Storage Cells (features/authentication/storage/)
- **user_store** - User data persistence
  - **Path**: `features/authentication/storage/user_store/`
  - **Purpose**: Manage user data storage and retrieval
  - **Subscribes**: `cbs.user_store.save`, `cbs.user_store.query`
  - **Publishes**: `cbs.user.saved`, `cbs.user.retrieved`

### Shared Domain (shared/)
#### Integration Cells (shared/integration/)
- **api_client** - HTTP API client
  - **Path**: `shared/integration/api_client/`
  - **Purpose**: Handle HTTP requests to external APIs
  - **Subscribes**: `cbs.api_client.request`, `cbs.api_client.upload`
  - **Publishes**: `cbs.api.response`, `cbs.api.error`

### Logic Cells ([N] cells)
- **${app}_core_logic** - Core business logic and processing
  - **Purpose**: Handle main application business rules
  - **Subscribes**: `cbs.core_logic.process`, `cbs.core_logic.validate`
  - **Publishes**: `cbs.data.processed`, `cbs.ui.update_required`

- **${app}_auth_logic** - Authentication and authorization
  - **Purpose**: Handle user authentication and permissions
  - **Subscribes**: `cbs.auth_logic.authenticate`, `cbs.auth_logic.authorize`
  - **Publishes**: `cbs.auth.result`, `cbs.session.created`

### Integration Cells ([N] cells)
- **${app}_api_client** - External API communication
  - **Purpose**: Handle external service integrations
  - **Subscribes**: `cbs.api_client.request`, `cbs.api_client.sync`
  - **Publishes**: `cbs.api.response`, `cbs.api.error`

### Storage Cells ([N] cells)
- **${app}_data_store** - Application data persistence
  - **Purpose**: Handle data storage and retrieval
  - **Subscribes**: `cbs.data_store.save`, `cbs.data_store.query`
  - **Publishes**: `cbs.data.saved`, `cbs.data.retrieved`
```

**Message Flow Diagrams**:
```
## Primary Message Flows

### User Authentication Flow
User Input → main_ui → auth_logic → data_store → auth_logic → main_ui → User

### Feature Processing Flow  
User Action → feature_ui → core_logic → data_store → core_logic → feature_ui → User

### External Integration Flow
Logic Cell → api_client → External Service → api_client → Logic Cell
```

</step>

<step number="4" name="validate_cell_architecture">

### Step 4: Validate Cell Architecture

Ensure the proposed cell breakdown follows CBS principles.

**CBS Compliance Validation**:

**Cell Isolation Check**:
```bash
# Verify each cell has single responsibility
# Check no direct cell-to-cell dependencies
# Validate all communication through bus
# Ensure cells can be developed independently
```

**Message Contract Validation**:
```bash
# Check all published subjects have subscribers
# Verify all subscribed subjects have publishers
# Validate message schema consistency
# Ensure proper error handling flows
```

**Architecture Quality Metrics**:
```markdown
## Architecture Validation Report

### ✅ CBS Compliance
- [x] All cells have single, clear responsibility
- [x] No direct cell-to-cell communication
- [x] All communication through typed bus messages
- [x] Cells can be developed and tested independently

### ✅ Message Contract Quality
- [x] All message flows have clear publishers/subscribers
- [x] Message schemas follow CBS envelope format
- [x] Error handling flows properly designed
- [x] Correlation IDs supported for request-response

### ✅ Architecture Quality
- [x] Reasonable cell count (not too granular/monolithic)
- [x] Clear separation of concerns
- [x] Reusable cell designs
- [x] Scalable message patterns

### ⚠️ Considerations
- [Consideration 1]: [Description and recommendation]
- [Consideration 2]: [Description and recommendation]

### 📊 Metrics
- **Total Cells**: [N]
- **Message Types**: [N]
- **Cell Dependencies**: [N] (via bus only)
- **Estimated Complexity**: [S/M/L]
```

</step>

<step number="5" name="create_cell_breakdown_document">

### Step 5: Create Cell Breakdown Document

Generate comprehensive documentation of the cell architecture.

**Cell Breakdown Document**:
```markdown
# Cell Breakdown - $CURRENT_APP

## Overview
- **Application**: $CURRENT_APP
- **Total Cells**: [N] cells
- **Breakdown Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Based on**: App specification v[X]

## Architecture Summary
- **UI Cells**: [N] - User interface and interactions
- **Logic Cells**: [N] - Business logic and processing
- **Integration Cells**: [N] - External service connections
- **Storage Cells**: [N] - Data persistence and retrieval
- **IO Cells**: [N] - Input/output operations

## Detailed Cell Specifications
[Detailed breakdown for each cell]

## Message Flow Architecture
[ASCII diagrams of message flows]

## Implementation Roadmap
### Phase 1: Foundation Cells
[Core cells needed first]

### Phase 2: Feature Cells  
[Feature-specific cells]

### Phase 3: Integration Cells
[External integration cells]

## Validation Results
[Results of CBS compliance and architecture validation]

## Next Steps
1. Review and approve cell breakdown
2. Create individual cell specifications
3. Implement cells following CBS patterns
```

</step>

<step number="6" name="present_for_approval">

### Step 6: Present Cell Breakdown for Approval

Show the complete cell architecture to the user for review and approval.

**Presentation Format**:
```markdown
## 🧬 Cell Breakdown Ready for Review

**Application**: $CURRENT_APP
**Total Cells**: [N] cells across [N] categories

### 📊 Architecture Summary
- **UI**: [N] cells for user interface
- **Logic**: [N] cells for business processing
- **Integration**: [N] cells for external services
- **Storage**: [N] cells for data management

### 🎯 Key Cells Identified
[Highlight the most important cells and their purposes]

### 📨 Message Flow Highlights
[Show key message flows between cells]

### ✅ Validation Status
- CBS Compliance: ✅ All cells follow CBS principles
- Message Contracts: ✅ Complete and consistent
- Architecture Quality: ✅ Well-designed separation of concerns

### 📄 Full Breakdown
Location: `applications/$CURRENT_APP/ai/cell_breakdown.md`

### 🔄 Review Options
1. **Approve**: Proceed to create individual cell specifications
2. **Refine**: Request changes to cell responsibilities or architecture
3. **Simplify**: Reduce number of cells or complexity
4. **Restart**: Major changes to approach

### 💬 What would you like to do?
- Type "approve" to proceed to cell specifications
- Type "refine: [description]" to modify the breakdown
- Type "simplify" to reduce complexity
- Type "restart" for major architectural changes
```

</step>

<step number="7" name="handle_approval_or_iteration">

### Step 7: Handle Approval or Continue Iteration

Process user feedback and either proceed to cell specifications or iterate.

**Approval Path**:
```bash
if [ "$USER_RESPONSE" = "approve" ]; then
  # Transition to cell_specs phase
  yq eval "
    .current_phase = \"cell_specs\" |
    .phases.cell_breakdown.status = \"completed\" |
    .phases.cell_specs.status = \"in_progress\"
  " .cbs-workflow-state > .cbs-workflow-state.tmp
  
  mv .cbs-workflow-state.tmp .cbs-workflow-state
  
  # Create cell directories
  for cell in $IDENTIFIED_CELLS; do
    mkdir -p "applications/$CURRENT_APP/cells/$cell/ai"
    mkdir -p "applications/$CURRENT_APP/cells/$cell/lib"
    mkdir -p "applications/$CURRENT_APP/cells/$cell/test"
  done
  
  echo "✅ Cell breakdown approved!"
  echo "🧬 Created directories for $CELL_COUNT cells"
  echo "🔄 Phase transition: cell_breakdown → cell_specs"
  echo ""
  echo "Next: Create individual cell specifications"
  echo "Command: cbs cell design <cell_name>"
fi
```

**Iteration Path**:
```bash
if [[ "$USER_RESPONSE" == "refine:"* ]]; then
  # Extract refinement details and iterate
  REFINEMENT="${USER_RESPONSE#refine: }"
  cbs iterate "Cell breakdown refinement: $REFINEMENT"
  
  # Return to architecture design with feedback
  echo "🔄 Refining cell breakdown based on feedback..."
fi
```

**Unlimited Iteration Support**:
- Continue iterating until user approves
- Each iteration creates snapshot for rollback
- Maintain complete change history
- User controls progression to next phase

</step>

</process_flow>

## Integration Points

### **With Application Workflow**:
- Requires completed app specification
- Transitions to cell specification phase
- Maintains application-level workflow state

### **With Cell Development**:
- Creates foundation for individual cell specifications
- Defines message contracts for cell implementation
- Sets up cell directory structure

### **With Feature Addition**:
- Provides baseline cell architecture for feature analysis
- Enables feature impact assessment
- Supports feature-driven cell modifications

This instruction transforms application specifications into concrete cell architectures while maintaining CBS principles and supporting unlimited iteration refinement.
