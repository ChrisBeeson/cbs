---
description: CBS Workflow State Management for Iterative Development
version: 1.0
encoding: UTF-8
---

# CBS Workflow State Manager

## Overview

Manage workflow state across unlimited iterations of CBS application development. Track progress, handle rollbacks, and maintain consistency across development phases.

<cbs_context_check>
  EXECUTE: @cbs-agent/instructions/meta/cbs-context.md
</cbs_context_check>

## State File Structure

### Primary State File: `.cbs-workflow-state`
```yaml
# CBS Workflow State
version: "1.0"
created_at: "2025-09-20T00:00:00Z"
last_updated: "2025-09-20T00:00:00Z"

# Current workflow context
current_app: "my_application"
current_phase: "app_spec"  # app_spec | cell_breakdown | cell_specs | implementation | feature_addition
iteration_count: 3
active_cell: ""  # For cell-focused work

# Phase tracking
phases:
  app_spec:
    status: "completed"  # pending | in_progress | completed | blocked
    iteration: 2
    completed_at: "2025-09-20T00:00:00Z"
    last_modified: "2025-09-20T00:00:00Z"
    spec_path: "applications/my_application/.cbs-spec/app_spec.md"
    
  cell_breakdown:
    status: "in_progress"
    iteration: 1
    started_at: "2025-09-20T00:00:00Z"
    breakdown_path: "applications/my_application/ai/cell_breakdown.md"
    
  cell_specs:
    status: "pending"
    cells: []
    
  implementation:
    status: "pending"
    completed_cells: []
    active_tasks: []
    
  feature_addition:
    status: "pending"
    features: []

# Iteration history
iterations:
  - id: 1
    phase: "app_spec"
    timestamp: "2025-09-20T00:00:00Z"
    description: "Initial application specification created"
    changes: ["Created basic app structure", "Defined core features"]
    
  - id: 2
    phase: "app_spec"  
    timestamp: "2025-09-20T00:00:00Z"
    description: "Updated authentication requirements"
    changes: ["Added OAuth integration", "Updated user stories"]
    
  - id: 3
    phase: "cell_breakdown"
    timestamp: "2025-09-20T00:00:00Z"
    description: "Started cell breakdown analysis"
    changes: ["Identified 5 core cells", "Defined message contracts"]

# Snapshots for rollback
snapshots:
  iteration_1: "snapshots/iteration_1.tar.gz"
  iteration_2: "snapshots/iteration_2.tar.gz"
```

## State Management Commands

### State Initialization
<step number="1" name="initialize_workflow_state">

**Command**: `cbs workflow init <app_name>`

**Process**:
1. Create `.cbs-workflow-state` file
2. Set initial phase to "app_spec"
3. Create application directory structure
4. Set CBS application context
5. Create initial snapshot

**Output**:
```bash
✅ Workflow initialized for application: my_application
📁 Created: applications/my_application/
📝 State file: .cbs-workflow-state
🎯 Current phase: app_spec (iteration 0)
```

</step>

### Phase Transition Management
<step number="2" name="manage_phase_transitions">

**Automatic Transitions**:
- User approval triggers phase advancement
- Failed validation blocks phase transition
- Rollbacks return to previous phase state

**Phase Validation**:
```bash
# Before transitioning to cell_breakdown
- ✅ App spec exists and is complete
- ✅ User has approved app spec
- ✅ No blocking issues identified

# Before transitioning to cell_specs  
- ✅ Cell breakdown document exists
- ✅ All cells have defined responsibilities
- ✅ Message contracts are specified
- ✅ User has approved breakdown

# Before transitioning to implementation
- ✅ All cell specs exist
- ✅ Cell specs are valid and complete
- ✅ Dependencies are properly defined
- ✅ User has approved all specs
```

</step>

### Iteration Tracking
<step number="3" name="track_iterations">

**Iteration Creation**:
```bash
cbs workflow iterate --phase <phase> --description "What changed"
```

**Process**:
1. **Snapshot Current State**: Save current files
2. **Increment Iteration**: Update iteration count
3. **Log Changes**: Record what was modified
4. **Update Timestamps**: Track when iteration occurred
5. **Validate State**: Ensure state remains consistent

**Iteration Metadata**:
- **Change Description**: What the user wanted to modify
- **Files Modified**: List of files changed in this iteration
- **Validation Results**: Whether changes passed validation
- **User Approval**: Whether user approved the changes

</step>

## State Query and Display

### Status Display
<step number="4" name="display_workflow_status">

**Command**: `cbs workflow status`

**Output Format**:
```bash
🧬 CBS Workflow Status
═══════════════════════

📦 Application: my_application
🎯 Current Phase: cell_breakdown (iteration 1)
📅 Last Updated: 2 hours ago

Phase Progress:
✅ app_spec        (completed, iteration 2)
🔄 cell_breakdown  (in_progress, iteration 1)  
⏳ cell_specs      (pending)
⏳ implementation  (pending)
⏳ feature_addition (pending)

Recent Activity:
• 2h ago: Started cell breakdown analysis
• 4h ago: Updated authentication requirements  
• 6h ago: Initial application specification created

Next Steps:
1. Complete cell breakdown document
2. Get user approval for cell responsibilities
3. Proceed to individual cell specifications

💡 Use 'cbs workflow help' for available commands
```

</step>

### History and Analytics
<step number="5" name="workflow_history">

**Command**: `cbs workflow history [--phase <phase>] [--limit <n>]`

**Detailed History**:
```bash
📊 Workflow History - my_application

Iteration 3 (current) - cell_breakdown
├─ Started: 2 hours ago
├─ Description: Started cell breakdown analysis  
├─ Changes: Identified 5 core cells, Defined message contracts
└─ Status: in_progress

Iteration 2 - app_spec  
├─ Completed: 4 hours ago
├─ Description: Updated authentication requirements
├─ Changes: Added OAuth integration, Updated user stories
├─ Duration: 1.5 hours
└─ Status: completed

Iteration 1 - app_spec
├─ Completed: 6 hours ago  
├─ Description: Initial application specification created
├─ Changes: Created basic app structure, Defined core features
├─ Duration: 2 hours
└─ Status: completed

📈 Analytics:
• Total iterations: 3
• Average iteration time: 1.8 hours
• Most active phase: app_spec (2 iterations)
• Current phase duration: 2 hours
```

</step>

## Rollback and Recovery

### Rollback System
<step number="6" name="rollback_management">

**Command**: `cbs workflow rollback <iteration_id>`

**Rollback Process**:
1. **Validate Target**: Ensure rollback target exists
2. **Create Current Snapshot**: Save current state before rollback
3. **Restore Files**: Restore files from target iteration
4. **Update State**: Reset workflow state to target iteration
5. **Validate Restoration**: Ensure restored state is valid
6. **Notify User**: Confirm successful rollback

**Rollback Safety**:
- Always create snapshot before rollback
- Validate restored state integrity
- Maintain rollback history
- Allow re-rollback if needed

**Example**:
```bash
$ cbs workflow rollback 2
⚠️  This will rollback to iteration 2 (Updated authentication requirements)
📸 Creating snapshot of current state...
🔄 Restoring files from iteration 2...
✅ Rollback completed successfully

Current state:
🎯 Phase: app_spec (iteration 2)
📝 Restored: applications/my_application/.cbs-spec/app_spec.md
🕐 Rollback time: 30 seconds ago
```

</step>

### State Recovery
<step number="7" name="state_recovery">

**Corruption Detection**:
- Missing required files
- Invalid state file format
- Inconsistent phase/iteration data
- Broken file references

**Recovery Process**:
1. **Detect Issues**: Identify state corruption
2. **Backup Current**: Save corrupted state for analysis
3. **Find Last Valid**: Locate most recent valid snapshot
4. **Restore State**: Restore from valid snapshot
5. **Validate Recovery**: Ensure recovered state works
6. **Log Recovery**: Document what was recovered

**Manual Recovery**:
```bash
cbs workflow recover --from-snapshot <snapshot_id>
cbs workflow repair --fix-references
cbs workflow validate --fix-errors
```

</step>

## Integration with Development Phases

### App Spec Phase Integration
<step number="8" name="app_spec_state_integration">

**State Updates During App Spec**:
- Track spec file modifications
- Log user feedback and changes
- Monitor approval status
- Record iteration reasons

**State-Aware Commands**:
```bash
cbs app-spec create    # Initializes app_spec phase
cbs app-spec iterate   # Creates new app_spec iteration
cbs app-spec approve   # Marks app_spec as completed
```

</step>

### Cell Development Integration
<step number="9" name="cell_development_state_integration">

**Cell-Level State Tracking**:
```yaml
cells:
  user_auth:
    status: "spec_complete"  # spec_pending | spec_complete | implementation_pending | implementation_complete
    spec_path: "applications/my_app/cells/user_auth/.cbs-spec/spec.md"
    tasks_path: "applications/my_app/cells/user_auth/ai/tasks.md"
    iteration: 2
    last_modified: "2025-09-20T00:00:00Z"
    
  data_processor:
    status: "spec_pending"
    iteration: 1
```

**Cell State Commands**:
```bash
cbs cell status <cell_name>           # Show individual cell status
cbs cells status                      # Show all cells status
cbs cell iterate <cell_name>          # Create new cell iteration
```

</step>

### Feature Addition State
<step number="10" name="feature_state_integration">

**Feature Tracking**:
```yaml
features:
  user_notifications:
    status: "spec_complete"
    spec_path: "cbs-agent/specs/2025-09-20-user-notifications/spec.md"
    affected_cells: ["user_auth", "notification_service"]
    new_cells: ["notification_service"]
    iteration: 1
    
  advanced_search:
    status: "implementation_pending"  
    affected_cells: ["search_engine", "ui_search"]
    iteration: 3
```

</step>

## Error Handling and Validation

### State Validation
<step number="11" name="state_validation">

**Validation Checks**:
- State file format correctness
- Referenced files exist
- Phase progression logic
- Iteration sequence integrity
- Snapshot availability

**Auto-Repair**:
- Fix missing timestamps
- Repair broken file references
- Rebuild iteration history from snapshots
- Validate and fix phase status

</step>

### Error Recovery
<step number="12" name="error_recovery">

**Common Errors**:
- Corrupted state file
- Missing snapshots
- Invalid phase transitions
- Broken file references

**Recovery Strategies**:
- Restore from most recent valid snapshot
- Rebuild state from existing files
- Manual state reconstruction
- Emergency reset with data preservation

</step>

## Performance and Scalability

### Efficient State Management
- **Lazy Loading**: Load state data only when needed
- **Incremental Updates**: Update only changed portions
- **Compressed Snapshots**: Use compression for snapshot storage
- **Cleanup**: Remove old snapshots based on retention policy

### Large Application Support
- **Chunked Processing**: Handle large applications in chunks
- **Parallel Operations**: Process multiple cells simultaneously
- **Memory Management**: Optimize memory usage for large state files
- **Background Tasks**: Use background processing for heavy operations

This state management system ensures reliable tracking of unlimited iterations while maintaining performance and data integrity.
