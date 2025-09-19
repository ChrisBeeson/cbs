# Technical Specification

This is the technical specification for the spec detailed in @ai/.agent-os/specs/2025-09-15-enhanced-bus-monitor/spec.md

## Technical Requirements

### CBS Cell Architecture Compliance
- BusMonitorCell implements Cell trait with `id()`, `subjects()`, and `register(BodyBus)` methods
- Cell subscribes to `cbs.>` wildcard pattern to capture all bus messages
- Cell maintains complete isolation - no direct communication with other cells
- All enhancements contained within the single BusMonitorCell implementation

### Schema Enhancement
- Add optional `description` field to CBS Envelope schema in both Rust (body_core) and Dart (cbs_sdk) implementations
- Maintain backward compatibility with existing messages that don't include descriptions
- Support description field in JSON schema validation
- Cell receives enhanced envelopes via bus subscription

### Channel Information Extraction
- Extract NATS subject from envelope using `envelope.subject()` method (format: `cbs.{service}.{verb}`)
- Display full channel path in monitor UI with clear visual distinction
- Implement channel-based color coding within the cell's display logic
- No modification to other cells required

### Payload Type Detection Within Cell
- Implement payload type inference from `envelope.schema` field within BusMonitorCell
- Parse schema format (`service/version/PayloadType`) to extract type name
- Display payload type prominently in message list items
- Handle error payloads and empty payloads gracefully
- All parsing logic contained within the monitor cell

### UI/UX Enhancements (Cell-Internal)
- Expand BusMessage data structure to include computed properties for channel, payload type, description
- Implement responsive design that works on different screen sizes
- Add visual hierarchy: Channel > Service.Verb > Payload Type > Description
- Maintain current color coding system while adding new information layers
- Ensure performance remains optimal with additional data display

### Description Registry Within Cell
- Create schema-to-description mapping system within BusMonitorCell
- Support both static (compile-time) and dynamic (runtime) description lookup
- Implement fallback descriptions for unknown schemas within cell
- Design extensible system for adding new schema descriptions to the cell

### Cell State Management
- Maintain enhanced message history within cell's ValueNotifier
- Handle message clearing and UI state management independently
- Ensure cell can be disposed/removed without affecting other components
- All state and logic encapsulated within BusMonitorCell boundaries
