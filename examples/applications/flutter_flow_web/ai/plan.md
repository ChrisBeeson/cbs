## Application Plan: flutter_flow_web

**spec**: `examples/applications/flutter_flow_web/ai/spec.md`
**tasks**: `examples/applications/flutter_flow_web/ai/tasks.md`
**cell_map**: `examples/applications/flutter_flow_web/ai/cell_map.md`

### Goals
- Playground app with navbar, Home, Monitor screens, live Bus Monitor
- Clean CBS separation; bus-only communication; 60fps UI

### Non-goals
- No direct cell imports; no DB writes; no backend migrations

### Deliverables
- Navigation system (logic/ui cells) integrated with existing cells
- Screen cells: `screen_home`, `screen_monitor`
- Updated birthmap and app wiring
- Tests: unit, integration, basic UI

### Milestones
- M1 Spec review complete; tasks validated
- M2 `navigation_manager` logic cell implemented + tested
- M3 `navbar_ui` cell implemented + tested
- M4 `screen_home` + `screen_monitor` cells implemented + tested
- M5 End-to-end flow; docs updated; cell map regenerated

### Architecture notes
- Messages: `cbs.nav.*`, `cbs.ui.*`, `cbs.monitor.*`
- Envelope schema with versioning; correlate via `correlation_id`
- State via Riverpod; logs via `log.d/e/i/w()`; keep handlers light

### Testing
- Logic: pure unit tests on reducers/services
- Bus: subscribe/publish integration tests per subject
- UI: golden tests for navbar; smoke tests for screens

### Acceptance checklist (Spec Kit inspired)
- Clear scope, constraints, and message contracts
- Tasks cover end-to-end path with tests and docs
- No inter-cell imports; only bus messages
- Performance: no jank; handlers < 4ms
- Docs: spec, plan, tasks, research updated

Reference: Spec-Driven Development guidance from [Spec Kit](https://github.com/github/spec-kit/tree/main)



