## Application Spec: flutter_flow_web

**id**: flutter_flow_web
**name**: flutter_flow_web  
**version**: 1.0.0  
**language**: dart
**category**: application
**type**: web  
**purpose**: Playground UI with Flow text and a live Bus Monitor.

### Interface
- subscribe: cbs.app.start
- subscribe: cbs.app.stop
- publish: cbs.app.ready
- publish: cbs.app.shutdown

### Cells
- flow_ui (dart, ui) → `examples/applications/flutter_flow_web/cells/flow_ui`
- bus_monitor (dart, integration) → `examples/applications/flutter_flow_web/cells/bus_monitor`
- flow_text (dart, ui) → `examples/applications/flutter_flow_web/cells/flow_text`

### Runtime
- Config file: `examples/applications/flutter_flow_web/app.yaml`
- Bus SDK: `shared_cells/dart/cbs_sdk`

### Flows
- ui_render: `cbs.flow_ui.render`
- user_toggle: `cbs.flow_ui.toggle`
- clear_messages: `cbs.bus_monitor.clear`

### Birthmap
- See `examples/applications/flutter_flow_web/birthmap.yaml` for concrete cells/deps.

### Constraints
- Strict bus-only comms between cells; no direct imports across cell boundaries.
- Keep UI at 60fps; avoid heavy sync work in handlers.


