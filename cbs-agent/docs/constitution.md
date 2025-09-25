# CBS Constitution

## Preamble

This constitution establishes the foundational principles, architectural laws, and development standards for the Cell Body System (CBS). These principles are **immutable** and **non-negotiable** - they form the core identity of CBS and enable all its benefits.

**This document is the single source of truth for CBS principles.**

---

## Article I: The Cardinal Rule

### Section 1.1: Bus-Only Communication Law

**THE CARDINAL RULE: Cells MUST ONLY communicate through the bus - NEVER directly**

This is not a suggestion, guideline, or best practice. This is an **architectural law** that enables everything else CBS provides.

#### Forbidden Practices
- ❌ Direct method calls between cells
- ❌ Shared objects or state between cells  
- ❌ Direct imports of other cells
- ❌ Synchronous cell-to-cell communication
- ❌ Global variables accessible by multiple cells

#### Required Practices
- ✅ All communication via typed `Envelope` messages
- ✅ Asynchronous message-based interaction
- ✅ Complete cell isolation
- ✅ Bus-mediated data exchange
- ✅ Contract-first development

### Section 1.2: Enforcement

**Violation of the Cardinal Rule is a breaking change that fundamentally compromises CBS architecture.**

- All cells must be validated for bus-only communication
- Direct cell dependencies are prohibited at build time
- Code reviews must verify message-only interaction
- Automated tooling must detect and prevent violations

---

## Article II: Cellular Architecture Principles

### Section 2.1: Cell Isolation

**Each cell is a completely independent organism that:**

- Operates in complete isolation from other cells
- Has no knowledge of other cells' existence
- Cannot directly affect other cells' state
- Communicates only through the message bus
- Can be developed, tested, and deployed independently

### Section 2.2: Single Responsibility

**Each cell has exactly one clear capability:**

- Performs one well-defined function
- Has a clear, single purpose
- Maps to one domain responsibility
- Is named by its capability, not its technology

### Section 2.3: Cell Categories

**Cells are organized into five categories:**

- **`ui`**: User interface components and interactions
- **`logic`**: Business logic and data processing
- **`storage`**: Data persistence and caching
- **`integration`**: External service connections
- **`io`**: Input/output operations

### Section 2.4: Self-Containment

**Each cell is a self-contained unit that:**

- Includes all dependencies needed for its function
- Can be built and tested in isolation
- Has clear boundaries defined by message contracts
- Maintains its own internal state (if any)
- Handles its own errors gracefully

---

## Article III: Message-Based Communication

### Section 3.1: Envelope Standard

**All communication uses typed `Envelope` messages with:**

```json
{
  "id": "correlation-uuid",
  "service": "service_name",
  "verb": "action_name", 
  "schema": "domain/v1/TypeName",
  "payload": { /* data */ },
  "error": null
}
```

### Section 3.2: Subject Format

**Message subjects follow the pattern:**
- Format: `cbs.{service}.{verb}`
- Example: `cbs.user_service.get_profile`
- Use snake_case for service and verb names
- Be specific and descriptive

### Section 3.3: Schema Versioning

**Message schemas use semantic versioning:**
- Format: `domain/v{major}/TypeName`
- Examples: `user/v1/Profile`, `payment/v2/Transaction`
- Breaking changes require major version bump
- Support N-1 versions when possible

### Section 3.4: Correlation Tracking

**Every message includes correlation ID for:**
- Request tracing across cells
- Debugging message flows
- Performance monitoring
- Error investigation

---

## Article IV: Contract-First Development

### Section 4.1: Specification Requirement

**Every cell MUST have `ai/spec.md` defining:**

- Cell purpose and responsibility
- Message contracts (subscribe/publish)
- Data models and schemas
- Error handling patterns
- Testing requirements

### Section 4.2: Design Before Implementation

**Message contracts must be designed before coding:**

1. Define message interfaces first
2. Specify payload schemas
3. Design error responses
4. Plan message flows
5. Then implement cells

### Section 4.3: Contract Immutability

**Published contracts are immutable:**
- Breaking changes require new major versions
- Backward compatibility is required
- Deprecation follows semantic versioning
- Migration paths must be provided

---

## Article V: Quality Standards

### Section 5.1: Testing Requirements

**Every cell must have:**

- Unit tests for business logic
- Integration tests for message handling
- Mock bus tests for isolation
- Error scenario coverage
- Performance benchmarks

### Section 5.2: Code Quality

**All cell code must:**

- Follow language-specific best practices
- Use structured logging with correlation IDs
- Handle errors gracefully
- Be documented and maintainable
- Pass static analysis tools

### Section 5.3: CBS Compliance

**All cells must pass CBS validation:**

- Bus-only communication verification
- Message contract validation
- Cell isolation checks
- Specification completeness
- Architecture compliance

---

## Article VI: Development Standards

### Section 6.1: Directory Structure

**Standard cell structure:**
```
applications/<app>/cells/<cell>/
  ai/spec.md          # Cell specification (required)
  lib/               # Implementation
  test/              # Tests  
  pubspec.yaml       # Dependencies (Dart)
  Cargo.toml         # Dependencies (Rust)
```

### Section 6.2: Naming Conventions

**Consistent naming across CBS:**

- Cell IDs: `snake_case` (e.g., `user_service`)
- Message subjects: `cbs.service.verb` (e.g., `cbs.user_service.get_profile`)
- Schema names: `domain/v1/TypeName` (e.g., `user/v1/Profile`)
- File names: Follow language conventions

### Section 6.3: Error Handling

**Standardized error responses:**

- Structured error envelopes
- Clear error codes and messages
- Correlation ID preservation
- Graceful degradation patterns
- No silent failures

---

## Article VII: Architectural Constraints

### Section 7.1: Language Freedom

**CBS supports polyglot development:**

- Cells can be implemented in any supported language
- Language choice based on cell requirements
- Seamless inter-language communication via bus
- Shared SDK available for each language

### Section 7.2: Scalability Design

**Architecture supports natural scaling:**

- Stateless cell design for horizontal scaling
- NATS queue groups for load balancing
- Independent cell deployment
- Distributed system ready

### Section 7.3: Fault Isolation

**Failures are contained:**

- Cell crashes don't affect other cells
- Bus handles connection failures
- Graceful degradation patterns
- Observable error propagation

---

## Article VIII: Governance

### Section 8.1: Constitutional Authority

**This constitution is the supreme law of CBS:**

- All other documentation must align with these principles
- Any conflicts are resolved in favor of the constitution
- Changes require explicit constitutional amendment
- Violations must be corrected immediately

### Section 8.2: Amendment Process

**Constitutional changes require:**

1. Clear justification for the change
2. Impact analysis on existing systems
3. Migration strategy for breaking changes
4. Community review and consensus
5. Formal ratification process

### Section 8.3: Enforcement Mechanisms

**CBS provides tooling to enforce constitutional principles:**

- `cbs validate` - Full compliance checking
- `cbs isolation` - Bus-only communication verification  
- `cbs-spec` - Contract validation
- Build-time constraint checking
- Runtime monitoring and alerts

---

## Article IX: Benefits and Guarantees

### Section 9.1: Architectural Guarantees

**Following this constitution guarantees:**

- **Zero Coupling**: Cells are completely independent
- **Language Freedom**: Mix languages naturally
- **Fault Isolation**: Failures don't cascade
- **Natural Scaling**: NATS handles load balancing
- **Hot Swapping**: Replace cells without system restart
- **Full Observability**: Every interaction is visible

### Section 9.2: Development Benefits

**Constitutional compliance provides:**

- **True Modularity**: Components evolve independently
- **Testability**: Mock the bus, not complex objects
- **Maintainability**: Clear boundaries and contracts
- **Reusability**: Cells work across applications
- **Predictability**: Consistent patterns and practices

### Section 9.3: Operational Benefits

**Production systems gain:**

- **Reliability**: Isolated failure domains
- **Scalability**: Independent scaling per cell
- **Observability**: Complete message tracing
- **Flexibility**: Easy system evolution
- **Performance**: Optimized message routing

---

## Article X: Violations and Remedies

### Section 10.1: Constitutional Violations

**The following are constitutional violations:**

- Direct cell-to-cell method calls
- Shared state between cells
- Missing cell specifications
- Non-compliant message formats
- Bypassing the message bus

### Section 10.2: Detection and Reporting

**Violations are detected through:**

- Automated validation tools
- Code review processes
- Runtime monitoring
- Static analysis
- Architecture audits

### Section 10.3: Remediation Requirements

**Violations must be corrected by:**

- Refactoring direct calls to message-based communication
- Creating proper message contracts
- Adding missing specifications
- Implementing proper error handling
- Ensuring bus-only communication

---

## Conclusion

This constitution establishes CBS as a **revolutionary software architecture** based on biological principles. By enforcing these foundational laws, CBS enables:

- **True modularity** where components can evolve independently
- **Natural scalability** that grows with your needs
- **Language freedom** to use the best tool for each job
- **Built-in observability** for debugging and monitoring  
- **Fault isolation** that prevents cascading failures
- **Evolutionary architecture** that improves over time

**The principles in this constitution are not suggestions - they are the foundational laws that make CBS possible.**

**Ratified:** September 21, 2025  
**Version:** 1.0  
**Authority:** CBS Core Team  
**Status:** Active and Enforceable

---

*"In CBS, we trust the bus, embrace isolation, and let cells evolve independently."*
