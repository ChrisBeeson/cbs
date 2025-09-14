# Cell Architecture Specification

This document details the cell architecture and modular design patterns for the Flutter Bus Monitor and Flow Text cells.

## Cell Structure Overview

### Directory Layout
```
applications/flutter_flow_web/cells/
├── bus_monitor/
│   ├── lib/
│   │   └── bus_monitor_cell.dart
│   ├── pubspec.yaml
│   └── test/
├── flow_text/
│   ├── lib/
│   │   └── flow_text_widget.dart
│   ├── pubspec.yaml
│   └── test/
└── flow_ui/
    ├── lib/
    │   └── flow_ui_cell.dart
    ├── pubspec.yaml
    └── test/
```

## Cell Interface Implementation

### Bus Monitor Cell

**CBS Cell Compliance:**
```dart
class BusMonitorCell implements Cell {
  @override
  String get id => 'bus_monitor';
  
  @override
  List<String> get subjects => ['cbs.>'];
  
  @override
  Future<void> register(BodyBus bus) async {
    await bus.subscribe('cbs.>', _handleAllMessages);
  }
}
```

**Key Responsibilities:**
- Subscribe to all CBS messages using wildcard pattern
- Maintain in-memory message history with reactive updates
- Provide color-coded message display logic
- Handle message clearing and UI state management

### Flow Text Cell

**Modular Widget Design:**
```dart
class FlowTextWidget extends StatelessWidget {
  // Configurable display component
}

class FlowTextCell {
  // State management for visibility
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier(true);
}
```

**Key Responsibilities:**
- Provide reusable "Flow" text component with styling
- Manage visibility state independently
- Support responsive design across device sizes
- Enable customization of colors, effects, and sizing

### Flow UI Cell (Orchestrator)

**Integration Pattern:**
```dart
class FlowUIWidget extends StatefulWidget {
  // Combines bus monitor and flow text cells
  final BusMonitorCell _busMonitor = BusMonitorCell();
  final FlowTextCell _flowTextCell = FlowTextCell();
}
```

**Key Responsibilities:**
- Orchestrate multiple cells in unified UI
- Handle cross-cell interactions and state
- Manage layout and visual composition
- Provide user controls for cell operations

## Dependency Management

### Cell-Level Dependencies

**Bus Monitor Cell (`pubspec.yaml`):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cbs_sdk:
    path: ../../../../shared_cells/dart/cbs_sdk
```

**Flow Text Cell (`pubspec.yaml`):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  # No external dependencies - pure Flutter widget
```

**Flow UI Cell (`pubspec.yaml`):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cbs_sdk:
    path: ../../../../shared_cells/dart/cbs_sdk
  bus_monitor_cell:
    path: ../bus_monitor
  flow_text_cell:
    path: ../flow_text
```

### Application-Level Dependencies

**Main Application (`pubspec.yaml`):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cbs_sdk:
    path: ../../shared_cells/dart/cbs_sdk
  flow_ui_cell:
    path: cells/flow_ui
  bus_monitor_cell:
    path: cells/bus_monitor
  flow_text_cell:
    path: cells/flow_text
```

## Reusability Patterns

### Independent Cell Usage

**Bus Monitor in Other Apps:**
```dart
// Import and use in any CBS Flutter app
import 'package:bus_monitor_cell/bus_monitor_cell.dart';

final monitor = BusMonitorCell();
await monitor.register(bus);
```

**Flow Text in Other UIs:**
```dart
// Use as standalone widget component
import 'package:flow_text_cell/flow_text_widget.dart';

FlowTextWidget(
  visible: true,
  color: Colors.purple,
  fontSize: 64.0,
)
```

### Composition Patterns

**Custom Cell Combinations:**
```dart
class CustomDashboard extends StatefulWidget {
  // Combine cells in different layouts
  final BusMonitorCell busMonitor = BusMonitorCell();
  final FlowTextCell flowText = FlowTextCell();
  // Add other cells as needed
}
```

## Testing Architecture

### Unit Testing Pattern

**Cell Logic Testing:**
```dart
// Test cell behavior independently
test('should capture bus messages', () async {
  final cell = BusMonitorCell();
  final envelope = Envelope.newRequest(/*...*/);
  
  await cell._handleAllMessages(envelope);
  
  expect(cell.messages, hasLength(1));
});
```

### Widget Testing Pattern

**UI Component Testing:**
```dart
// Test widget rendering and interactions
testWidgets('should toggle flow text visibility', (tester) async {
  await tester.pumpWidget(FlowTextWidget(visible: true));
  expect(find.text('Flow'), findsOneWidget);
});
```

### Integration Testing Pattern

**End-to-End Cell Testing:**
```dart
// Test cell registration and bus integration
test('should register with bus successfully', () async {
  final mockBus = MockBus();
  final cell = BusMonitorCell();
  
  await cell.register(mockBus);
  
  verify(mockBus.subscribe('cbs.>', any)).called(1);
});
```

## Performance Considerations

### Memory Management

**Resource Cleanup:**
```dart
@override
void dispose() {
  _flowTextCell.dispose();  // Clean up ValueNotifiers
  _scrollController.dispose();  // Clean up controllers
  super.dispose();
}
```

### UI Optimization

**Efficient List Rendering:**
- Use `ListView.builder` for large message lists
- Implement auto-scroll with smooth animations
- Color-code messages without expensive computations

### State Management

**Reactive Updates:**
- `ValueNotifier` for efficient UI rebuilds
- Minimal state changes to prevent unnecessary renders
- Clean separation of data and presentation logic
