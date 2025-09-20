---
description: Build and implement a CBS cell from approved specification
version: 1.0
encoding: UTF-8
---

# Build CBS Cell

## Overview

Implement a CBS cell from its approved specification using TDD, proper bus communication, and cell isolation principles. Generate tasks, implement code, and validate integration.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

<process_flow>

<step number="1" name="validate_cell_ready_for_build">

### Step 1: Validate Cell Ready for Build

Ensure the cell has an approved specification and is ready for implementation.

**Prerequisites Check**:
```bash
# Check workflow state
CURRENT_APP=$(yq eval '.current_app' .cbs-workflow-state)
CURRENT_PHASE=$(yq eval '.current_phase' .cbs-workflow-state)

# Get cell name (from parameter or context)
if [ -z "$CELL_NAME" ]; then
  CELL_NAME=$(yq eval '.active_cell' .cbs-workflow-state)
  if [ -z "$CELL_NAME" ] || [ "$CELL_NAME" = "null" ]; then
    echo "❌ No cell specified"
    echo "Usage: cbs cell build <cell_name>"
    exit 1
  fi
fi

# Validate cell specification exists
CELL_SPEC_PATH="applications/$CURRENT_APP/cells/$CELL_NAME/ai/spec.md"
if [ ! -f "$CELL_SPEC_PATH" ]; then
  echo "❌ Cell specification not found: $CELL_SPEC_PATH"
  echo "Create cell spec first: cbs cell design $CELL_NAME"
  exit 1
fi

# Check spec is approved (not in draft state)
if grep -q "Status: Draft\|Status: Pending" "$CELL_SPEC_PATH"; then
  echo "⚠️  Cell specification not yet approved"
  echo "Approve spec first or use: cbs cell refine $CELL_NAME"
  read -p "Continue anyway? (y/N): " -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
```

**Cell Analysis**:
- Extract cell metadata (id, language, category, purpose)
- Parse message contracts (subscribe/publish subjects)
- Identify dependencies and communication patterns
- Validate CBS compliance of specification

</step>

<step number="2" name="generate_implementation_tasks">

### Step 2: Generate Implementation Tasks

Create specific, actionable tasks for implementing the cell.

**Task Generation Based on Cell Type**:

**UI Cell Tasks** (category: ui):
```markdown
# Cell Implementation Tasks - $CELL_NAME (UI)

## Tasks

- [ ] 1. **Set Up Cell Interface and Registration**
  - [ ] 1.1 Write tests for Cell trait implementation
  - [ ] 1.2 Implement Cell trait (id, subjects, register)
  - [ ] 1.3 Create bus registration for UI event subjects
  - [ ] 1.4 Add message handler stubs for UI interactions
  - [ ] 1.5 Verify cell registers correctly with bus

- [ ] 2. **Implement UI Components**
  - [ ] 2.1 Write widget tests for UI components
  - [ ] 2.2 Create main widget structure and layout
  - [ ] 2.3 Implement user interaction handlers
  - [ ] 2.4 Add state management with ValueNotifiers
  - [ ] 2.5 Apply styling and responsive design
  - [ ] 2.6 Verify all UI tests pass

- [ ] 3. **Implement Bus Message Handling**
  - [ ] 3.1 Write tests for message envelope processing
  - [ ] 3.2 Implement handlers for subscribed subjects
  - [ ] 3.3 Add message publishing for user actions
  - [ ] 3.4 Implement error handling and user feedback
  - [ ] 3.5 Add correlation ID tracking
  - [ ] 3.6 Verify all message handling tests pass

- [ ] 4. **Integration and Validation**
  - [ ] 4.1 Write integration tests for complete UI workflows
  - [ ] 4.2 Test cell with mock bus and real message flows
  - [ ] 4.3 Validate cell isolation (no direct dependencies)
  - [ ] 4.4 Test error scenarios and recovery
  - [ ] 4.5 Verify performance and responsiveness
  - [ ] 4.6 Run full cell validation suite
```

**Logic Cell Tasks** (category: logic):
```markdown
# Cell Implementation Tasks - $CELL_NAME (Logic)

## Tasks

- [ ] 1. **Set Up Cell Interface and Registration**
  - [ ] 1.1 Write tests for Cell trait implementation
  - [ ] 1.2 Implement Cell trait with business logic subjects
  - [ ] 1.3 Create bus registration for processing subjects
  - [ ] 1.4 Add message handler stubs for business operations
  - [ ] 1.5 Verify cell registers correctly with bus

- [ ] 2. **Implement Core Business Logic**
  - [ ] 2.1 Write unit tests for core algorithms and processing
  - [ ] 2.2 Implement main business logic functions
  - [ ] 2.3 Add data validation and transformation logic
  - [ ] 2.4 Implement error handling and edge cases
  - [ ] 2.5 Add logging and monitoring
  - [ ] 2.6 Verify all unit tests pass

- [ ] 3. **Implement Bus Message Processing**
  - [ ] 3.1 Write tests for envelope processing and responses
  - [ ] 3.2 Implement message handlers for each business operation
  - [ ] 3.3 Add result publishing to appropriate subjects
  - [ ] 3.4 Implement error envelope publishing
  - [ ] 3.5 Add request correlation and response tracking
  - [ ] 3.6 Verify all message processing tests pass

- [ ] 4. **Performance and Integration Testing**
  - [ ] 4.1 Write performance tests for business logic
  - [ ] 4.2 Test cell with realistic data volumes
  - [ ] 4.3 Validate processing times and resource usage
  - [ ] 4.4 Test concurrent message handling
  - [ ] 4.5 Verify error recovery and resilience
  - [ ] 4.6 Run full cell validation and performance suite
```

**Integration Cell Tasks** (category: integration):
```markdown
# Cell Implementation Tasks - $CELL_NAME (Integration)

## Tasks

- [ ] 1. **Set Up Cell Interface and External Connections**
  - [ ] 1.1 Write tests for Cell trait and connection management
  - [ ] 1.2 Implement Cell trait with integration subjects
  - [ ] 1.3 Set up external service connections (API clients, etc.)
  - [ ] 1.4 Add message handlers for integration operations
  - [ ] 1.5 Verify cell registers and connects correctly

- [ ] 2. **Implement External Service Integration**
  - [ ] 2.1 Write tests for external service interactions
  - [ ] 2.2 Implement API client or service connector
  - [ ] 2.3 Add authentication and authorization handling
  - [ ] 2.4 Implement data transformation between formats
  - [ ] 2.5 Add retry logic and error handling
  - [ ] 2.6 Verify all integration tests pass

- [ ] 3. **Implement Bus Message Bridge**
  - [ ] 3.1 Write tests for CBS ↔ external service message bridging
  - [ ] 3.2 Implement inbound message processing from bus
  - [ ] 3.3 Add external service call execution
  - [ ] 3.4 Implement response transformation and publishing
  - [ ] 3.5 Add timeout and error envelope handling
  - [ ] 3.6 Verify all bridging tests pass

- [ ] 4. **Reliability and Error Handling**
  - [ ] 4.1 Write tests for failure scenarios and recovery
  - [ ] 4.2 Implement circuit breaker patterns
  - [ ] 4.3 Add monitoring and health checks
  - [ ] 4.4 Test network failures and service outages
  - [ ] 4.5 Verify graceful degradation
  - [ ] 4.6 Run full reliability test suite
```

</step>

<step number="3" name="execute_implementation_tasks">

### Step 3: Execute Implementation Tasks

Implement the cell following the generated tasks using TDD approach.

**TDD Implementation Cycle**:
```bash
# For each major task
for task in $MAJOR_TASKS; do
  echo "🔨 Starting task: $task"
  
  # Execute subtasks in order
  for subtask in $SUBTASKS; do
    echo "  📝 Executing: $subtask"
    
    # Implement subtask with TDD
    # 1. Write tests first (if test subtask)
    # 2. Implement minimal code to pass tests
    # 3. Refactor while keeping tests green
    # 4. Validate CBS compliance
    
    # Mark subtask complete
    update_task_status "$subtask" "completed"
  done
  
  # Mark major task complete
  update_task_status "$task" "completed"
  echo "✅ Completed task: $task"
done
```

**CBS-Specific Implementation Guidelines**:
- **Bus Registration**: Always implement Cell trait first
- **Message Handling**: Implement exact message contracts from spec
- **Error Handling**: Publish error envelopes on failures
- **Logging**: Use `log.d/i/w/e` with correlation IDs
- **Testing**: Unit tests for logic, integration tests for bus communication

</step>

<step number="4" name="validate_cell_implementation">

### Step 4: Validate Cell Implementation

Ensure the implemented cell follows CBS principles and works correctly.

**Validation Suite**:
```bash
# Run cell-specific tests
cd "applications/$CURRENT_APP/cells/$CELL_NAME"
case "$CELL_LANGUAGE" in
  "dart")
    flutter test
    ;;
  "rust") 
    cargo test
    ;;
  "python")
    pytest
    ;;
esac

# Run CBS validation
cbs validate --specs "applications/$CURRENT_APP/cells/$CELL_NAME"

# Test bus communication
cbs cell debug $CELL_NAME --test-messages

# Validate isolation
cbs isolation validate --cell $CELL_NAME
```

**CBS Compliance Checks**:
- ✅ **Cell Trait**: Properly implements id(), subjects(), register()
- ✅ **Bus-Only**: No direct imports or calls to other cells
- ✅ **Message Contracts**: Implements exact subjects from specification
- ✅ **Error Handling**: Publishes error envelopes appropriately
- ✅ **Testing**: Adequate test coverage for logic and integration
- ✅ **Logging**: Proper logging with correlation IDs

</step>

<step number="5" name="integration_testing">

### Step 5: Integration Testing

Test the cell's integration with the broader CBS system.

**Integration Test Types**:

**Message Flow Testing**:
```bash
# Test complete message flows involving this cell
cbs messages trace $CELL_NAME --test-flow

# Example: If this is auth_logic cell
# Test: UI → auth_logic → user_store → auth_logic → UI
# Verify: Complete authentication flow works end-to-end
```

**Multi-Cell Scenarios**:
```bash
# Test scenarios involving multiple cells
# Start minimal CBS system with this cell + dependencies
# Send real messages through bus
# Verify expected behavior and responses
```

**Error Scenario Testing**:
```bash
# Test error handling and recovery
# Simulate network failures, invalid messages, timeouts
# Verify cell publishes appropriate error envelopes
# Confirm system remains stable
```

**Performance Testing**:
```bash
# Test cell performance under load
# Verify message processing times
# Check memory usage and resource consumption
# Validate concurrent message handling
```

</step>

<step number="6" name="update_workflow_and_complete">

### Step 6: Update Workflow and Complete

Update workflow state and mark cell as implemented.

**Workflow State Updates**:
```bash
# Mark cell as implemented
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

yq eval "
  .phases.implementation.completed_cells += [\"$CELL_NAME\"] |
  .phases.implementation.status = \"in_progress\" |
  .last_updated = \"$TIMESTAMP\"
" .cbs-workflow-state > .cbs-workflow-state.tmp

mv .cbs-workflow-state.tmp .cbs-workflow-state

# Create completion snapshot
cbs iterate "Completed implementation of $CELL_NAME cell"
```

**Completion Notification**:
```bash
echo "🎉 Cell Implementation Complete!"
echo ""
echo "✅ Cell: $CELL_NAME"
echo "📁 Location: applications/$CURRENT_APP/cells/$CELL_NAME"
echo "🧪 Tests: All passing"
echo "🚌 Bus Integration: Validated"
echo "🔒 Isolation: Confirmed"
echo ""
echo "🔄 Next Steps:"
echo "1. Build another cell: cbs cell build <next_cell>"
echo "2. Test integration: cbs cells debug"
echo "3. Add features: cbs feature add <feature_name>"
echo "4. Deploy application: cbs app deploy"
```

**Documentation Updates**:
- Update cell map with implemented cell
- Generate updated architecture documentation
- Update application README with cell status
- Create implementation summary

</step>

</process_flow>

## Advanced Features

### **Intelligent Task Generation**:
- Tasks adapt based on cell category and complexity
- Considers existing application architecture
- Suggests optimization opportunities
- Includes performance and security considerations

### **Real-Time Validation**:
- Continuous validation during implementation
- Immediate feedback on CBS compliance issues
- Live testing of message contracts
- Performance monitoring during development

### **Smart Debugging**:
- Automatic issue detection during implementation
- Suggested fixes for common CBS problems
- Message flow visualization and debugging
- Integration with CBS debugging tools

This instruction provides a complete, intuitive workflow for implementing CBS cells with proper validation, testing, and integration.
