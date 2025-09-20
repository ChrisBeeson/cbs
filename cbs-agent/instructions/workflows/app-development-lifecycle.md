---
description: Complete CBS Application Development Lifecycle with Unlimited Iterations
version: 1.0
encoding: UTF-8
---

# CBS Application Development Lifecycle

## Overview

Orchestrate the complete development lifecycle for multi-cell CBS applications with unlimited iteration support. Handle application specs, cell breakdown, implementation, and feature additions through iterative refinement cycles.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

## Workflow State Management

### Current State Tracking
```yaml
# .cbs-workflow-state
workflow_phase: "app_spec" | "cell_breakdown" | "implementation" | "feature_addition"
current_app: "app_name"
iteration_count: 0
last_updated: "2025-09-20T00:00:00Z"
active_specs:
  - app_spec: "path/to/app_spec.md"
  - cell_specs: ["cell1/spec.md", "cell2/spec.md"]
  - feature_specs: ["feature1/spec.md"]
completed_phases:
  - phase: "app_spec"
    iteration: 1
    completed_at: "timestamp"
pending_iterations:
  - phase: "cell_breakdown"
    reason: "user requested changes to authentication flow"
```

## Phase 1: Application Specification (Iterative)

### Initial App Spec Creation
<step number="1" name="create_initial_app_spec">

**Trigger**: User describes application idea or requests new app spec

**Actions**:
1. **Context Gathering**: Understand application purpose, users, key features
2. **Create App Spec**: Use `@cbs-agent/instructions/core/create-spec.md` adapted for application level
3. **Generate Structure**: Create `applications/{app_name}/ai/app_spec.md`
4. **Set State**: Update workflow state to `app_spec` phase

**Iteration Support**:
- **User Feedback**: Accept changes to requirements, scope, features
- **Spec Refinement**: Update app spec based on feedback
- **Version Tracking**: Maintain iteration history in spec comments
- **Continue Criteria**: User approval to proceed to cell breakdown

</step>

### App Spec Iteration Loop
<step number="2" name="iterate_app_spec">

**Trigger**: User requests changes to application specification

**Iteration Process**:
1. **Capture Changes**: Document what user wants to modify
2. **Impact Analysis**: Identify affected sections of app spec
3. **Update Spec**: Modify app_spec.md with changes
4. **Validation**: Ensure spec remains coherent and feasible
5. **User Review**: Present updated spec for approval
6. **State Update**: Increment iteration count, log changes

**Unlimited Iterations**: Continue until user says "proceed to cell breakdown"

</step>

## Phase 2: Cell Breakdown (Iterative)

### Automatic Cell Identification
<step number="3" name="break_down_into_cells">

**Trigger**: User approves app spec and requests cell breakdown

**Cell Analysis Process**:
1. **Feature Mapping**: Map app features to potential cells
2. **Responsibility Assignment**: Identify single responsibilities
3. **Communication Patterns**: Design bus message flows
4. **Cell Categories**: Assign ui/io/logic/integration/storage categories
5. **Generate Cell List**: Create initial cell breakdown document

**Cell Breakdown Output**:
```markdown
# Cell Breakdown - {App Name}

## Identified Cells

### Core Application Cells
- **user_auth** (integration) - Handle user authentication and sessions
  - Subscribes: `cbs.user_auth.login`, `cbs.user_auth.logout`
  - Publishes: `cbs.session.created`, `cbs.session.ended`

- **data_processor** (logic) - Process and transform application data
  - Subscribes: `cbs.data_processor.transform`
  - Publishes: `cbs.data.processed`

### UI Cells
- **main_ui** (ui) - Primary user interface components
  - Subscribes: `cbs.ui.render`, `cbs.ui.update`
  - Publishes: `cbs.user.action`

## Message Flow Diagram
[ASCII diagram of cell communication]

## Implementation Priority
1. Core cells first (auth, data)
2. UI cells second
3. Integration cells last
```

</step>

### Cell Breakdown Iteration
<step number="4" name="iterate_cell_breakdown">

**Iteration Triggers**:
- User wants different cell responsibilities
- User identifies missing cells
- User wants to merge/split cells
- User changes communication patterns

**Iteration Process**:
1. **Identify Changes**: What cells/responsibilities to modify
2. **Impact Analysis**: How changes affect other cells and message flows
3. **Update Breakdown**: Modify cell list and communication patterns
4. **Validate Isolation**: Ensure cells maintain proper isolation
5. **Update Message Contracts**: Adjust bus communication patterns
6. **User Review**: Present updated breakdown

**Continue Until**: User approves cell breakdown for implementation

</step>

## Phase 3: Cell Specification Creation (Iterative)

### Generate Individual Cell Specs
<step number="5" name="create_cell_specs">

**Trigger**: User approves cell breakdown

**For Each Cell**:
1. **Create Cell Directory**: `applications/{app}/cells/{cell_name}/`
2. **Generate Spec**: Use `@cbs-agent/instructions/core/execute-cell-spec.md`
3. **Define Interface**: Specify subjects, message schemas, behaviors
4. **Create Tests**: Define test scenarios and requirements
5. **Set Dependencies**: Identify cell dependencies and load order

**Batch Creation**: Generate all cell specs in parallel for efficiency

</step>

### Cell Spec Iteration
<step number="6" name="iterate_cell_specs">

**Iteration Triggers**:
- User wants to modify cell interfaces
- User identifies missing message contracts
- User changes cell responsibilities
- User adds/removes cell dependencies

**Per-Cell Iteration**:
1. **Focus Cell**: Set context to specific cell being modified
2. **Update Spec**: Modify `ai/spec.md` with changes
3. **Validate Contracts**: Ensure message contracts remain valid
4. **Check Dependencies**: Verify cell dependencies are correct
5. **Update Related Cells**: Modify cells that communicate with this one

**Continue Until**: User approves all cell specs for implementation

</step>

## Phase 4: Implementation (Iterative)

### Task Generation and Execution
<step number="7" name="implement_cells">

**Trigger**: User approves cell specs and requests implementation

**Implementation Process**:
1. **Generate Tasks**: Use `@cbs-agent/instructions/core/create-tasks.md` for each cell
2. **Prioritize Cells**: Implement in dependency order
3. **Execute Tasks**: Use `@cbs-agent/instructions/core/execute-tasks.md`
4. **Validate Implementation**: Run tests and validation
5. **Integration Testing**: Test cell communication via bus

**Per-Cell Implementation**:
- Generate tasks.md for cell
- Implement code following TDD
- Run cell-specific tests
- Validate bus communication
- Mark cell as complete

</step>

### Implementation Iteration
<step number="8" name="iterate_implementation">

**Iteration Triggers**:
- Tests failing and need code changes
- User wants implementation modifications
- Integration issues between cells
- Performance or design improvements needed

**Iteration Process**:
1. **Identify Issue**: What needs to be changed and why
2. **Impact Analysis**: Which cells are affected
3. **Update Implementation**: Modify code while maintaining contracts
4. **Re-run Tests**: Ensure changes don't break existing functionality
5. **Validate Integration**: Test cell communication still works
6. **User Review**: Demonstrate working functionality

**Continue Until**: All cells implemented and tests passing

</step>

## Phase 5: Feature Addition (Iterative)

### New Feature Specification
<step number="9" name="add_new_features">

**Trigger**: User requests new features for existing application

**Feature Addition Process**:
1. **Feature Spec**: Create feature specification using existing spec process
2. **Cell Impact Analysis**: Identify which existing cells need modification
3. **New Cell Identification**: Determine if new cells are needed
4. **Message Contract Updates**: Plan changes to bus communication
5. **Implementation Plan**: Create tasks for feature implementation

**Feature Types**:
- **Cell Modification**: Update existing cells with new functionality
- **New Cells**: Add entirely new cells to application
- **Integration Changes**: Modify how cells communicate
- **UI Enhancements**: Update user interface cells

</step>

### Feature Iteration
<step number="10" name="iterate_features">

**Unlimited Feature Iterations**:
- User can request multiple features simultaneously
- Each feature goes through spec → cell analysis → implementation cycle
- Features can be added, modified, or removed at any time
- Existing functionality is preserved through proper testing

**Iteration Management**:
1. **Queue Features**: Maintain list of requested features
2. **Prioritize**: Work on features in user-specified order
3. **Implement Incrementally**: Complete one feature before starting next
4. **Validate Continuously**: Ensure existing functionality remains intact
5. **User Feedback**: Get approval at each feature completion

</step>

## Iteration Management System

### State Persistence
```bash
# Workflow state commands
cbs workflow status                    # Show current workflow state
cbs workflow set-phase <phase>         # Set current phase
cbs workflow history                   # Show iteration history
cbs workflow rollback <iteration>      # Rollback to previous iteration
```

### Iteration Tracking
- **Automatic Versioning**: Each iteration creates versioned snapshots
- **Change Logging**: Track what changed in each iteration
- **Rollback Support**: Ability to return to previous iterations
- **Progress Indicators**: Show completion status for each phase

### User Commands
```bash
# Phase transitions
cbs app-spec create <app_name>         # Start new application
cbs app-spec iterate                   # Modify current app spec
cbs cells breakdown                    # Generate cell breakdown
cbs cells iterate                      # Modify cell breakdown
cbs cells implement                    # Start implementation
cbs feature add <feature_name>         # Add new feature
```

## Validation and Quality Gates

### Inter-Phase Validation
- **Spec Completeness**: Ensure specs are complete before proceeding
- **Cell Isolation**: Validate proper cell boundaries
- **Message Contracts**: Verify bus communication patterns
- **Test Coverage**: Ensure adequate testing at each phase

### Continuous Validation
- **Bus-Only Communication**: Enforce throughout all phases
- **CBS Standards Compliance**: Apply standards at every iteration
- **Integration Testing**: Validate cell communication works
- **User Acceptance**: Get user approval before phase transitions

## Error Handling and Recovery

### Iteration Failures
- **Rollback Capability**: Return to last working state
- **Partial Recovery**: Save work completed before failure
- **Error Documentation**: Log issues for future reference
- **User Notification**: Clear communication about what went wrong

### State Corruption
- **State Validation**: Check workflow state integrity
- **Automatic Repair**: Fix common state issues
- **Manual Recovery**: Tools for manual state correction
- **Backup/Restore**: Maintain backups of critical states

## Success Criteria

### Phase Completion
- **App Spec**: User approves application specification
- **Cell Breakdown**: User approves cell responsibilities and communication
- **Cell Specs**: User approves individual cell specifications
- **Implementation**: All tests pass and functionality works as specified
- **Features**: New features work without breaking existing functionality

### Overall Success
- **Working Application**: Complete CBS application with all requested features
- **Proper Isolation**: All cells communicate only through the bus
- **Test Coverage**: Comprehensive testing at cell and integration levels
- **User Satisfaction**: Application meets user requirements and expectations
- **Maintainable Code**: Clean, well-documented, CBS-compliant implementation

This lifecycle supports unlimited iterations at every phase while maintaining CBS principles and ensuring quality outcomes.
