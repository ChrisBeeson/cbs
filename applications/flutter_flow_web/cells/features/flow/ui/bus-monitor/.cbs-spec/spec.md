## Bus Monitor Cell — Human Spec

**id**: bus_monitor  
**name**: Bus Monitor  
**version**: 1.1.0  
**language**: dart  
**category**: integration
**purpose**: A read-only cell that listens to every CBS message and shows them in a clean UI

### What it is
- A read-only cell that listens to every CBS message and shows them in a clean UI.
- Completely isolated. No direct references to other cells. Bus-only communication.

### What it shows (per message)
- **Channel**: `cbs.<service>.<verb>`
- **Type**: parsed from `schema` (`<service>/<version>/<Type>` → `Type`)
- **Description**: `envelope.description` or registry fallback
- **Time**: `HH:mm:ss.SSS`
- **Color**: `ui=blue`, `logic=green`, `error=red`, `other=white70`

### Interface
- subscribe: cbs.>
- subscribe: cbs.bus_monitor.clear
- publish: cbs.bus_monitor.response
- **Envelope used**: `shared_cells/dart/cbs_sdk` `Envelope` (`id, service, verb, schema, payload, description?`)

### Rules
- Buffer last 500 messages (drop oldest when >500)
- Smooth auto-scroll to bottom on append
- Clear on `cbs.bus_monitor.clear`
- UI work ≤ 16ms/frame
- Logging: `log.d() / log.i() / log.w() / log.e()` from `examples/applications/flutter_flow_web/lib/utils/logger.dart`

### UI (clean, modern, dark)
- Background `#1A1A1A`, accents `#00D4FF`
- Header: title, count badge, Clear button
- Row: `[time]  channel • type • schema    description`
- Color code by message type; wrap gracefully; performant list

### Behavior
- On any message: compute fields → append → autoscroll → `log.d`
- On `cbs.bus_monitor.clear`: empty buffer → `log.i`
- If disposed: return `{ status: 'error', message: 'Cell is disposed' }`

### Internals (kept simple)
- `SchemaInfo.from(schema) -> { service, version, payloadType | 'Data' }`
- `MessageDescriptionRegistry.get(service, verb)` → string
- `classify(service, isError)` → `ui | logic | error | other`
- `BusMessage` holds `{ timestamp, envelope }` with computed getters

### Description registry (examples)
- `greeter.say_hello` → "Process user name for greeting"
- `flow_ui.toggle` → "Toggle Flow UI visibility"
- `bus_monitor.clear` → "Clear monitor messages"

### Test plan
- Capture: start→receive→count=1; correct color/type
- Clear: seed N→receive `cbs.bus_monitor.clear`→count=0
- Schema parse: `greeter/v1/Name`→`Name`; bad schema→`Data`
- Time format: `^\d{2}:\d{2}:\d{2}\.\d{3}$`
- Buffer cap: push 510→count=500 (drop oldest)
- Disposal: disposed→returns error

### Build checklist
1) Parsing helpers (`SchemaInfo`, `classify`) + unit tests
2) Description registry + getter
3) Extend `BusMessage` getters (`channel`, `payloadType`, `description`, `messageType`, `displayColor`, `formattedTimestamp`)
4) Buffer cap (500, drop-oldest)
5) Handle `cbs.bus_monitor.clear`
6) Header (count, Clear), row layout, dark theme
7) Smooth autoscroll (guard `hasClients`)
8) Wire `log.d/i/w/e`

### Acceptance
- Captures all via `cbs.>`; shows channel, type, description, time, color
- Clear works; buffer capped; UI responsive
- No cross-cell imports; bus-only; concise logs



