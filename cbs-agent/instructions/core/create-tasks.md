---
description: Create CBS cell implementation tasks from approved cell specifications
globs:
alwaysApply: false
version: 2.0
encoding: UTF-8
---

# CBS Cell Task Creation

## Overview

Create implementation tasks for CBS cells from approved cell specifications, ensuring proper bus-only communication and cell isolation throughout the development process.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<pre_flight_check>
  EXECUTE: @cbs-agent/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="validate_cell_context">

### Step 1: Validate Cell Context

Ensure we're working within a specific cell context with approved specifications.

**Context Validation**:
- Verify current cell is set in workflow state
- Check cell specification exists and is approved
- Validate cell follows CBS principles
- Confirm cell has defined message contracts

**Required Files**:
- `applications/{app}/cells/{cell}/ai/spec.md` - Approved cell specification
- Cell directory structure with `lib/` and `test/` folders
- Workflow state showing cell_specs phase completed

</step>

<step number="2" name="analyze_cell_specification">

### Step 2: Analyze Cell Specification

Parse the approved cell specification to understand implementation requirements.

**Specification Analysis**:
- **Cell Identity**: Extract id, name, version, language, category
- **Message Contracts**: Identify subjects to subscribe/publish
- **Dependencies**: Note other cells this cell communicates with
- **Business Logic**: Understand core functionality requirements
- **Testing Requirements**: Extract test scenarios from spec

**CBS-Specific Requirements**:
- Bus-only communication patterns
- Message envelope handling
- Error propagation through bus
- Cell isolation maintenance
- Queue group assignments

</step>

<step number="3" name="create_cell_tasks">

### Step 3: Create Cell Implementation Tasks

Generate implementation tasks based on CBS cell development patterns.

<task_structure>
  <cbs_task_pattern>
    - Major Task: Cell component (Interface, Logic, Tests)
    - Subtasks: TDD cycle with bus integration
    - Always start with tests, end with integration validation
    - Each task maintains cell isolation
  </cbs_task_pattern>
  <task_categories>
    - Cell Interface Setup (message handlers, bus registration)
    - Core Logic Implementation (business logic, data processing)
    - Bus Communication (message publishing, error handling)
    - Integration Testing (bus message flows, cell isolation)
  </task_categories>
</task_structure>

<cbs_task_template>
  # Cell Implementation Tasks - {CELL_NAME}

  ## Tasks

  - [ ] 1. **Set Up Cell Interface and Bus Registration**
    - [ ] 1.1 Write tests for Cell trait implementation (id, subjects, register)
    - [ ] 1.2 Implement Cell trait with correct id and subject list
    - [ ] 1.3 Create bus registration logic for all subscribed subjects
    - [ ] 1.4 Add message handler stubs for each subscribed subject
    - [ ] 1.5 Verify cell registers correctly with bus

  - [ ] 2. **Implement Core Cell Logic**
    - [ ] 2.1 Write unit tests for core business logic functions
    - [ ] 2.2 Implement primary business logic without bus dependencies
    - [ ] 2.3 Add data validation and error handling
    - [ ] 2.4 Implement helper functions and utilities
    - [ ] 2.5 Verify all unit tests pass

  - [ ] 3. **Implement Bus Message Handling**
    - [ ] 3.1 Write tests for message envelope processing
    - [ ] 3.2 Implement message handlers for each subscribed subject
    - [ ] 3.3 Add message publishing for outbound communications
    - [ ] 3.4 Implement error envelope publishing for failures
    - [ ] 3.5 Add correlation ID tracking for request-response patterns
    - [ ] 3.6 Verify all message handling tests pass

  - [ ] 4. **Integration Testing and Validation**
    - [ ] 4.1 Write integration tests for bus communication flows
    - [ ] 4.2 Test cell behavior with mock bus and real message flows
    - [ ] 4.3 Validate cell isolation (no direct dependencies on other cells)
    - [ ] 4.4 Test error handling and timeout scenarios
    - [ ] 4.5 Verify all integration tests pass
    - [ ] 4.6 Run full cell validation suite
</cbs_task_template>

<cbs_ordering_principles>
  - **Cell-First**: Focus on single cell implementation
  - **Bus-Only**: All inter-cell communication through bus
  - **TDD Approach**: Tests before implementation
  - **Isolation**: Maintain cell boundaries throughout
  - **Message Contracts**: Implement exact specification contracts
  - **Error Handling**: Proper error propagation via bus
</cbs_ordering_principles>

</step>

<step number="2" name="execution_readiness">

### Step 2: Execution Readiness Check

Evaluate readiness to begin implementation by presenting the first task summary and requesting user confirmation to proceed.

<readiness_summary>
  <present_to_user>
    - Spec name and description
    - First task summary from tasks.md
    - Estimated complexity/scope
    - Key deliverables for task 1
  </present_to_user>
</readiness_summary>

<execution_prompt>
  PROMPT: "The spec planning is complete. The first task is:

  **Task 1:** [FIRST_TASK_TITLE]
  [BRIEF_DESCRIPTION_OF_TASK_1_AND_SUBTASKS]

  Would you like me to proceed with implementing Task 1? I will focus only on this first task and its subtasks unless you specify otherwise.

  Type 'yes' to proceed with Task 1, or let me know if you'd like to review or modify the plan first."
</execution_prompt>

<execution_flow>
  IF user_confirms_yes:
  REFERENCE: @cbs-agent/instructions/core/execute-tasks.md
    FOCUS: Only Task 1 and its subtasks
    CONSTRAINT: Do not proceed to additional tasks without explicit user request
  ELSE:
    WAIT: For user clarification or modifications
</execution_flow>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @cbs-agent/instructions/meta/post-flight.md
</post_flight_check>
