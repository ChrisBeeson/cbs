# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-09-15-flutter-bus-monitor-cells/spec.md

## Technical Requirements

### Bus Monitor Cell Implementation
- **Cell ID**: `bus_monitor` with wildcard subject subscription `'cbs.>'` to capture all CBS messages
- **Message Storage**: In-memory list with `ValueNotifier<List<BusMessage>>` for reactive UI updates
- **Message Structure**: `BusMessage` class containing `DateTime timestamp` and `Envelope envelope`
- **Color Coding**: UI messages (blue), logic messages (green), error messages (red), others (white70)
- **Auto-scroll**: Automatic scroll to bottom when new messages arrive using `ScrollController`
- **Message Clearing**: `clearMessages()` method to reset message history

### Flow Text Cell Implementation  
- **Modular Widget**: `FlowTextWidget` as standalone component accepting visibility, colors, and sizing parameters
- **State Management**: `FlowTextCell` class with `ValueNotifier<bool>` for visibility toggle
- **Responsive Design**: Font size adapts based on screen width (48px mobile, 72px tablet, 96px desktop)
- **Visual Effects**: Glow shadows, gradient underline, customizable colors with default cyan theme
- **Toggle Controls**: `toggleVisibility()`, `setVisibility(bool)`, and `isVisible` getter methods

### UI Integration Requirements
- **Split Layout**: Row-based layout with flow text (left) and bus messages (right) using `Expanded` flex widgets
- **Theme Consistency**: Dark theme (#1A1A1A background) with cyan accents (#00D4FF) throughout
- **Interactive Controls**: Toggle button with eye icons and clear messages button with proper visual feedback
- **Message Display**: Scrollable list in bordered container with header showing message count
- **Empty State**: Placeholder UI when no messages captured with appropriate icons and text

### Performance Specifications
- **Message Limit**: No artificial limit on message count (relies on Flutter's ListView.builder efficiency)
- **Memory Management**: Proper disposal of `ValueNotifier` and `ScrollController` resources
- **Scroll Performance**: Smooth auto-scroll animation (300ms duration, easeOut curve)
- **UI Responsiveness**: Non-blocking message capture and display updates

### Testing Requirements
- **Unit Tests**: Comprehensive test coverage for `BusMonitorCell` message handling and `FlowTextCell` state management
- **Widget Tests**: UI component testing for visibility toggles and message display
- **Integration Tests**: End-to-end testing of cell registration and bus message flow
- **Mock Testing**: Bus simulation for testing without NATS dependency

### Logger Integration
- **Logging Utility**: Custom logger with `log.d()`, `log.i()`, `log.w()`, `log.e()` methods
- **Debug Logging**: Message capture events, visibility toggles, and component lifecycle
- **Error Logging**: Bus connection issues, message parsing failures, and widget disposal errors

### Architecture Patterns
- **Cell Interface**: All components implement CBS `Cell` trait with `id`, `subjects`, and `register()` methods
- **Separation of Concerns**: Data logic in cell classes, UI logic in widget classes
- **Dependency Injection**: Clean interfaces between bus, cells, and UI components
- **Reactive Programming**: `ValueNotifier` pattern for state management and UI updates
