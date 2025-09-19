## Flow UI Cell Spec

**id**: flow_ui  
**name**: Flow UI Renderer  
**version**: 1.0.0  
**language**: dart  
**category**: ui  
**purpose**: Split UI showing Flow text and a Bus Monitor panel.

### Interface
- subscribe: cbs.flow_ui.render
- subscribe: cbs.flow_ui.toggle_flow_text
- subscribe: cbs.flow_ui.clear_messages
- publish: cbs.flow_text.toggle_visibility
- publish: cbs.bus_monitor.clear
- publish: cbs.flow_ui.toggle
- **subject format**: `cbs.<service>.<verb>`
- **schema format (current)**: `<service>.<verb>.v1` (matches code)
- **envelope**: `shared_cells/dart/cbs_sdk` `Envelope`

### Message contracts
- flow_ui.toggle_flow_text.v1 (subscribe)
  - payload: `{ previous_state: bool, timestamp: iso8601 }`
  - action: Forward toggle request to flow_text cell via bus
- flow_ui.clear_messages.v1 (subscribe)
  - payload: `{ timestamp: iso8601, user_initiated: bool }`
  - action: Forward clear request to bus_monitor cell via bus
- flow_text.toggle_visibility.v1 (publish)
  - payload: `{}`
  - subject: `cbs.flow_text.toggle_visibility`
- bus_monitor.clear.v1 (publish)
  - payload: `{ action: 'messages_cleared', timestamp: iso8601, user_initiated: true }`
  - subject: `cbs.bus_monitor.clear`

### Behavior
- **BUS-ONLY COMMUNICATION**: No direct cell-to-cell method calls or property access
- Register only self on the bus - no direct instantiation of other cells
- Forward UI requests to appropriate cells via bus messages
- No blocking work on UI thread; target 60fps (~16ms per frame)

### UI
- Dark background `#1A1A1A`, cyan accents `#00D4FF`.
- Left: `FlowTextWidget(visible)`; Right: Bus monitor panel with header and list.

### Errors
- If disposed: return `{ status: 'error', message: 'Cell is disposed' }`.

### Tests
- toggle_visibility: visible=true → publish toggle → visible=false.
- clear_messages: publish bus_monitor.clear → monitor list empties.

### Logging
- Prefer `examples/applications/flutter_flow_web/lib/utils/logger.dart` (`log.d/i/w/e`).

### Notes
- **CRITICAL**: FlowUICell must NOT directly instantiate or call methods on other cells
- UI composition is handled by FlowUIWidget which subscribes to bus messages for state updates
- All inter-cell communication MUST go through the bus using typed envelopes
- FlowUIWidget manages local state by subscribing to visibility and message update events



