## Flow Text Cell Spec

**id**: flow_text  
**name**: Flow Text Cell  
**version**: 1.0.0  
**language**: dart  
**category**: ui  
**purpose**: Render the 'Flow' headline with glow and responsive sizing.

### Interface
- subscribe: cbs.flow_text.get_content
- publish: cbs.flow_text.content_ready

### API
- `visibilityNotifier: ValueNotifier<bool>` current visibility
- `toggleVisibility()` flips state and logs
- `setVisibility(bool)` sets explicit state

### UI contract
- `FlowTextWidget(visible: bool, fontSize?, color?, glowColor?, letterSpacing?, shadows?)`
- Responsive font sizing by screen width: 48/72/96
- Theme color cyan `#00D4FF`, subtle gradient underline

### Behavior
- Stateless rendering, external state via `FlowTextCell`.
- 60fps target.

### Tests
- toggle: visible=true → toggle → false.

### Logging
- Prefer `log.d` for state changes.



