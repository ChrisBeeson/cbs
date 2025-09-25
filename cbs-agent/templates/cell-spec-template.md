# {{CELL_NAME}} Cell Specification

## Overview
- **Cell ID**: `{{CELL_ID}}`
- **Name**: {{CELL_NAME}}
- **Version**: 1.0.0
- **Category**: {{CATEGORY}} (ui/logic/storage/integration/io)
- **Language**: {{LANGUAGE}} (dart/rust/python/go/ts)
- **Purpose**: [One sentence describing the cell's single responsibility]

## Problem Statement
**What problem does this cell solve?**
- [Describe the specific problem this cell addresses]
- [What gap does it fill in the application architecture?]
- [Why is this cell necessary?]

## Requirements
### Functional Requirements
- **FR-1**: [Specific functional requirement]
- **FR-2**: [Specific functional requirement]
- **FR-3**: [Specific functional requirement]

### Non-Functional Requirements
- **Performance**: [Response time, throughput targets]
- **Reliability**: [Uptime, error rate targets]
- **Scalability**: [Load handling requirements]
- **Security**: [Authentication, authorization needs]

## User Stories
1. **As a [user/system]**, I want [capability] so that [benefit]
2. **As a [user/system]**, I want [capability] so that [benefit]
3. **As a [user/system]**, I want [capability] so that [benefit]

## Interface Specification
### Message Bus Contracts
**Subscribes To:**
- `cbs.{{SERVICE}}.{{VERB}}` - [Purpose and payload description]
- `cbs.{{SERVICE}}.{{VERB}}` - [Purpose and payload description]

**Publishes:**
- `cbs.{{SERVICE}}.{{VERB}}` - [Purpose and payload description]
- `cbs.{{SERVICE}}.{{VERB}}` - [Purpose and payload description]

### Message Schemas
```yaml
# Input Message Schema
{{SERVICE}}.{{VERB}}.v1:
  payload:
    field1: string
    field2: number
    field3: boolean
  metadata:
    correlation_id: string
    timestamp: iso8601
    version: "v1"

# Output Message Schema  
{{SERVICE}}.{{VERB}}.v1:
  payload:
    result: object
    status: "success" | "error"
  metadata:
    correlation_id: string
    timestamp: iso8601
    version: "v1"
```

### Error Handling
- **Validation Errors**: [How validation failures are handled]
- **Processing Errors**: [How processing failures are handled]
- **Timeout Errors**: [How timeouts are handled]
- **Recovery Strategy**: [How the cell recovers from errors]

## Data Model
```yaml
# Core data structures used by this cell
{{ENTITY_NAME}}:
  id: uuid
  name: string
  status: enum [active, inactive]
  created_at: datetime
  updated_at: datetime

{{RELATED_ENTITY}}:
  id: uuid
  {{ENTITY_NAME}}_id: uuid (foreign key)
  data: object
  metadata: object
```

## Business Logic
### Core Rules
1. **Rule 1**: [Business rule description]
2. **Rule 2**: [Business rule description]
3. **Rule 3**: [Business rule description]

### Validation Rules
- [Input validation requirements]
- [Data integrity requirements]
- [Business constraint requirements]

### State Management
- **Initial State**: [Description of initial state]
- **State Transitions**: [Valid state changes]
- **Final States**: [Terminal states]

## Implementation Plan
### Phase 1: Core Infrastructure (Days 1-2)
- [ ] Set up cell structure and dependencies
- [ ] Implement basic message handling
- [ ] Create core data structures
- [ ] Write unit tests for business logic

### Phase 2: Feature Development (Days 3-5)
- [ ] Implement FR-1: [Feature description]
- [ ] Implement FR-2: [Feature description]
- [ ] Implement FR-3: [Feature description]
- [ ] Integration testing with message bus

### Phase 3: Polish & Optimization (Days 6-7)
- [ ] Performance optimization
- [ ] Error handling refinement
- [ ] Documentation completion
- [ ] End-to-end testing

## Testing Strategy
### Unit Tests
- [ ] Test business logic functions
- [ ] Test validation rules
- [ ] Test error conditions
- [ ] Test state transitions

### Integration Tests
- [ ] Test message bus communication
- [ ] Test with dependent cells (mocked)
- [ ] Test error propagation
- [ ] Test timeout handling

### Performance Tests
- [ ] Load testing under expected volume
- [ ] Stress testing under peak load
- [ ] Memory usage profiling
- [ ] Response time validation

## Dependencies
### Internal Dependencies
- **Cells**: [List of cells this cell depends on]
- **Shared Libraries**: [Common libraries used]

### External Dependencies
- **APIs**: [External APIs consumed]
- **Services**: [External services used]
- **Libraries**: [Third-party libraries]

## Monitoring & Observability
### Metrics
- **Performance Metrics**: [Key performance indicators]
- **Business Metrics**: [Business KPIs tracked]
- **Error Metrics**: [Error rates and types]

### Logging
- **Log Levels**: [When to use debug, info, warn, error]
- **Log Format**: [Structured logging format]
- **Correlation IDs**: [How to track requests]

### Alerts
- **Error Rate Alerts**: [When to alert on errors]
- **Performance Alerts**: [When to alert on performance]
- **Business Alerts**: [When to alert on business metrics]

## Security Considerations
- **Authentication**: [How the cell authenticates]
- **Authorization**: [How permissions are checked]
- **Data Protection**: [How sensitive data is handled]
- **Audit Trail**: [What actions are logged]

## Deployment & Operations
### Configuration
- **Environment Variables**: [Required configuration]
- **Feature Flags**: [Runtime behavior toggles]
- **Resource Limits**: [Memory, CPU limits]

### Rollout Strategy
- **Blue-Green**: [If applicable]
- **Canary**: [If applicable]
- **Feature Flags**: [For gradual rollout]

### Rollback Plan
- **Rollback Triggers**: [When to rollback]
- **Rollback Process**: [How to rollback]
- **Data Migration**: [How to handle data changes]

## Success Criteria
### Acceptance Criteria
- [ ] All functional requirements implemented
- [ ] All user stories satisfied
- [ ] Performance targets met
- [ ] Security requirements satisfied
- [ ] All tests passing

### Definition of Done
- [ ] Code reviewed and approved
- [ ] Tests written and passing
- [ ] Documentation completed
- [ ] Security review passed
- [ ] Performance benchmarks met
- [ ] Deployed to staging successfully

## Review & Acceptance Checklist
### Technical Review
- [ ] Architecture aligns with CBS principles
- [ ] Message contracts are well-defined
- [ ] Error handling is comprehensive
- [ ] Performance requirements are realistic
- [ ] Security considerations are addressed

### Business Review
- [ ] Requirements are clear and complete
- [ ] User stories map to business value
- [ ] Success criteria are measurable
- [ ] Timeline is realistic
- [ ] Resource requirements are identified

### Implementation Readiness
- [ ] All dependencies identified
- [ ] Development environment ready
- [ ] Testing strategy defined
- [ ] Deployment plan created
- [ ] Monitoring plan established

## Notes
- **CBS Compliance**: This cell MUST communicate only through the message bus
- **Single Responsibility**: This cell has one clear purpose and responsibility
- **Reusability**: This cell is designed to be reused across applications
- **Testability**: This cell can be tested in isolation with mocked dependencies

