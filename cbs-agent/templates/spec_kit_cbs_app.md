# Spec-Kit + CBS Application Specification Template

## Product Requirements Document (PRD) - Spec-Kit Section

### Overview
- **Product Name**: {{APP_NAME}}
- **Version**: 1.0.0
- **Owner**: {{TEAM}}
- **Status**: Draft | In Review | Approved | In Development | Released

### Problem Statement
- **User Problem**: [What specific problem does this solve?]
- **Current Solution Gaps**: [What's missing in existing solutions?]
- **Success Metrics**: [How will we measure success?]

### User Stories & Requirements
#### Primary Users
- **User Type 1**: [Role, needs, goals]
- **User Type 2**: [Role, needs, goals]

#### Core User Stories
1. **As a [user type]**, I want [capability] so that [benefit]
2. **As a [user type]**, I want [capability] so that [benefit]
3. **As a [user type]**, I want [capability] so that [benefit]

#### Functional Requirements
- **FR-1**: [Detailed functional requirement]
- **FR-2**: [Detailed functional requirement]
- **FR-3**: [Detailed functional requirement]

#### Non-Functional Requirements
- **Performance**: [Response time, throughput requirements]
- **Security**: [Authentication, authorization, data protection]
- **Scalability**: [Expected load, growth projections]
- **Accessibility**: [WCAG compliance, device support]

### Technical Specification - Spec-Kit Section

#### Architecture Decisions
- **Frontend**: [Technology choice and rationale]
- **Backend**: [Technology choice and rationale]
- **Database**: [Technology choice and rationale]
- **Deployment**: [Platform choice and rationale]

#### API Specification
```yaml
# OpenAPI/Swagger spec or equivalent
endpoints:
  - path: /api/v1/resource
    method: GET
    description: [Purpose]
    parameters: [List]
    responses: [Expected responses]
```

#### Data Models
```yaml
# Core data structures
User:
  id: string
  name: string
  email: string
  created_at: datetime

Resource:
  id: string
  user_id: string (foreign key)
  data: object
  updated_at: datetime
```

---

## CBS Implementation Specification

### CBS Contracts
- **Envelope schema**: `framework/docs/schemas/envelope.schema.json`
- **Subject pattern**: `cbs.{service}.{verb}` (snake_case)
- **Message versioning**: `service.verb.v1`

### Cell Architecture
Based on the functional requirements above, decompose into CBS cells:

| Cell | ID | Category | Language | Purpose | Subscribes | Publishes |
|------|----|-----------|-----------|-----------|-----------|---------| 
| {{CELL_1}} | {{cell_1_id}} | {{ui/logic/storage/integration/io}} | {{dart/rust/python}} | [Single responsibility] | [cbs.service.verb] | [cbs.service.verb] |
| {{CELL_2}} | {{cell_2_id}} | {{category}} | {{language}} | [Single responsibility] | [cbs.service.verb] | [cbs.service.verb] |

### Message Flow Architecture
Map user stories to CBS message sequences:

#### User Story FR-1 Implementation
```
User Action → UI Cell → Logic Cell → Storage Cell → Response
1. cbs.ui.user_action (user input)
2. cbs.logic.process_request (business logic)  
3. cbs.storage.save_data (persistence)
4. cbs.ui.update_display (UI update)
```

#### User Story FR-2 Implementation
```
[Define message flow for second user story]
```

### Cell Specifications Preview
Each cell will have detailed `.cbs-spec/spec.md` following CBS standards:
- **Interface contracts** (subscribe/publish subjects)
- **Message schemas** with versioning
- **Error handling** patterns
- **Testing requirements** (unit, integration, bus)
- **Performance targets**

### Implementation Phases

#### Phase 1: Core Infrastructure 
- [ ] Set up CBS application structure
- [ ] Implement core cells: [list]
- [ ] Basic message bus communication
- [ ] Unit tests for business logic

#### Phase 2: Feature Development 
- [ ] Implement user stories FR-1, FR-2
- [ ] Integration testing
- [ ] UI/UX implementation
- [ ] End-to-end testing

#### Phase 3: Polish & Deploy
- [ ] Performance optimization
- [ ] Security hardening  
- [ ] Documentation completion
- [ ] Deployment automation

### Quality Assurance
- **Code Coverage**: Minimum 80% for logic cells
- **Performance**: [Specific targets from NFRs]
- **Security**: [Security testing requirements]
- **Accessibility**: [A11y testing requirements]

### Risks & Mitigation
- **Risk 1**: [Technical risk and mitigation strategy]
- **Risk 2**: [Business risk and mitigation strategy]
- **Risk 3**: [Timeline risk and mitigation strategy]

### Success Criteria
- [ ] All functional requirements implemented
- [ ] Performance targets met
- [ ] Security requirements satisfied
- [ ] User acceptance criteria passed
- [ ] CBS cell isolation maintained (no direct cell-to-cell calls)

---

## Development Workflow Integration

### Spec-Kit Review Process
1. **PRD Review**: Stakeholders approve requirements
2. **Technical Review**: Architecture team approves technical spec
3. **Implementation Planning**: Break down into CBS cells and sprints

### CBS Implementation Process  
1. **Cell Specification**: Create detailed `.cbs-spec/spec.md` for each cell
2. **Bus Contract Design**: Define message schemas and flows
3. **Iterative Development**: Implement cells with bus-only communication
4. **Integration Testing**: Validate message flows work end-to-end
5. **Performance Validation**: Ensure non-functional requirements met

### Continuous Validation
- **Spec Compliance**: `python3 ai/scripts/validate_spec.py`
- **Cell Isolation**: `cbs-validate-isolation --all`
- **Message Contracts**: `validate_envelopes.sh`
- **Requirements Traceability**: Map implemented features back to PRD

### New CLI Features
- **Automated Implementation**: Use `cbs-workflow implement` to automate cell implementation based on specifications in `.cbs-spec/spec.md`. This ensures compliance with CBS standards and streamlines the development process.
- **Structured Planning**: Use `cbs-workflow plan` to generate a detailed implementation plan and task breakdown for your application. This helps in organizing tasks for each cell category and tracking progress through different phases.

## Notes
- **Spec-Kit Advantage**: Clear requirements and stakeholder alignment before coding
- **CBS Advantage**: Modular, testable, scalable cellular architecture  
- **Integration Benefit**: Specification-driven development with proven modular implementation
- **Quality Assurance**: Both methodologies emphasize testing and validation
- **Enhanced Workflow**: New CLI commands facilitate automated implementation and structured planning, enhancing developer productivity
