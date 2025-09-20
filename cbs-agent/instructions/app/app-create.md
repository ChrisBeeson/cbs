---
description: Create a new CBS multi-cell application from user requirements
version: 1.0
encoding: UTF-8
---

# Create CBS Application

## Overview

Create a new CBS application with proper workflow tracking, application specification, and directory structure. This is the starting point for all CBS application development.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="initialize_application_workflow">

### Step 1: Initialize Application Workflow

Set up the application with workflow tracking and proper CBS structure.

**User Input Required**:
- Application name (snake_case, e.g., `my_chat_app`)
- Brief description of what the application does
- Primary platform (web/mobile/desktop/cli)

**Workflow Initialization**:
```bash
# Initialize workflow state
cbs app-create $APP_NAME

# This creates:
# - applications/$APP_NAME/ directory
# - .cbs-workflow-state file
# - CBS application context
# - Initial snapshot for rollback
```

**Directory Structure Created**:
```
applications/$APP_NAME/
├── ai/
│   ├── app_spec.md         # Application specification (to be created)
│   └── cell_breakdown.md   # Cell breakdown (to be created)
├── cells/                  # Individual cells (to be created)
└── README.md              # Application documentation
```

</step>

<step number="2" name="gather_application_requirements">

### Step 2: Gather Application Requirements

Collect comprehensive requirements for the CBS application.

**Requirements Gathering**:
1. **Application Purpose**: What problem does this solve? (1-2 sentences)
2. **Target Users**: Who will use this? (primary user types)
3. **Core Features**: What are the main capabilities? (3-8 features)
4. **User Workflows**: How do users interact with the app?
5. **Technical Constraints**: Any specific requirements or limitations?
6. **Success Criteria**: How do we know it's working? (measurable outcomes)

**CBS-Specific Questions**:
- Will this need real-time features? (affects message patterns)
- Does it integrate with external services? (affects integration cells)
- What kind of data does it manage? (affects storage cells)
- How complex is the UI? (affects UI cell breakdown)

</step>

<step number="3" name="create_application_specification">

### Step 3: Create Application Specification

Generate comprehensive application specification document.

**App Spec Template**:
```markdown
# Application Specification - $APP_NAME

## Overview
- **Purpose**: [1-2 sentence description]
- **Platform**: [web/mobile/desktop/cli]
- **Architecture**: Cell-based with bus-only communication
- **Created**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Target Users
- **Primary**: [User type and needs]
- **Use Cases**: [How they'll use the app]

## Core Features
1. **[Feature Name]** - [User value and functionality]
2. **[Feature Name]** - [User value and functionality]
3. **[Feature Name]** - [User value and functionality]

## User Workflows
### Primary Workflow: [Name]
1. User [action] → [result]
2. System [process] → [outcome]
3. User [interaction] → [completion]

## Technical Requirements
- **Primary Language**: [Dart/Rust/Python]
- **Real-time Needs**: [Yes/No + details]
- **External Integrations**: [List services/APIs]
- **Data Management**: [Type and complexity]
- **Performance Requirements**: [Response times, throughput]

## Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## CBS Architecture Preview
Based on requirements, we anticipate:
- **UI Cells**: ~[N] cells for user interface
- **Logic Cells**: ~[N] cells for business logic  
- **Integration Cells**: ~[N] cells for external services
- **Storage Cells**: ~[N] cells for data management

## Next Steps
- Review and approve this specification
- Break down into individual cells
- Design message contracts between cells
```

</step>

<step number="4" name="validate_and_present">

### Step 4: Validate and Present for Approval

Validate the application specification and present to user for approval.

**Validation Checks**:
- **Completeness**: All sections filled out appropriately
- **CBS Feasibility**: Can be implemented with cell architecture
- **Clear Success Criteria**: Measurable and achievable outcomes
- **Technical Viability**: Requirements are realistic

**Presentation to User**:
```markdown
## 📋 Application Specification Created

**Application**: $APP_NAME
**Phase**: app_spec (iteration 1)

### 🎯 What We're Building
[Summary of purpose and key features]

### 👥 Target Users
[Summary of who will use this]

### 🏗️ Architecture Preview
- Estimated [N] cells across [N] categories
- [Message flow complexity assessment]
- [Integration complexity assessment]

### 📄 Full Specification
Location: `applications/$APP_NAME/ai/app_spec.md`

### 🔄 Next Steps
1. **Approve**: Proceed to cell breakdown
2. **Refine**: Make changes to requirements (use `cbs app refine`)
3. **Restart**: Major changes to scope or approach

**Ready to proceed?** Type "approve" or "refine: [what to change]"
```

</step>

<step number="5" name="handle_user_response">

### Step 5: Handle User Response

Process user feedback and either proceed or iterate.

**Response Handling**:
- **"approve"** → Transition to cell breakdown phase
- **"refine: [changes]"** → Start new iteration with changes
- **"restart"** → Reset to requirements gathering

**On Approval**:
- Mark app_spec phase as completed
- Transition to cell_breakdown phase  
- Create snapshot of approved state
- Notify user of next steps

**On Refinement**:
- Create new iteration with user changes
- Update application specification
- Re-validate and present again
- Continue until approved

</step>

</process_flow>

## Integration Points

### **With Workflow System**
- Updates `.cbs-workflow-state` throughout process
- Creates snapshots for rollback capability
- Tracks iterations and changes
- Manages phase transitions

### **With CBS Tools**
- Uses `cbs validate` for specification validation
- Integrates with `cbs context` for application context
- Updates cell maps and documentation
- Follows CBS standards throughout

### **Next Instructions**
- **Success** → `app-breakdown.md` (break into cells)
- **Refinement** → `app-refine.md` (iterate on spec)
- **Feature Addition** → `feature-add.md` (add features later)

This instruction creates the foundation for all CBS application development with proper workflow tracking and unlimited iteration support.
