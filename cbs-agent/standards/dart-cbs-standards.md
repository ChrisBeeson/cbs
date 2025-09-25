# Dart/Flutter CBS Development Standards

## 🎯 Overview

Specific standards for developing CBS cells in Dart/Flutter, ensuring proper CBS compliance, modern Flutter practices, and lint-free code.

## 🧬 CBS Cell Implementation Standards

### **Cell Trait Implementation**
```dart
// ✅ Correct CBS Cell implementation
import 'package:cbs_sdk/cbs_sdk.dart';

class MyCellNameCell implements Cell {
  @override
  String get id => 'my_cell_name';  // snake_case, matches directory name
  
  @override
  List<String> get subjects => [
    'cbs.my_cell_name.process',
    'cbs.my_cell_name.update',
  ];
  
  @override
  Future<void> register(Bus bus) async {
    await bus.subscribe('cbs.my_cell_name.process', _handleProcess);
    await bus.subscribe('cbs.my_cell_name.update', _handleUpdate);
  }
  
  Future<Envelope> _handleProcess(Envelope envelope) async {
    // Implementation here
    return envelope.createResponse({'status': 'processed'});
  }
}
```

### **Message Handling Standards**
```dart
// ✅ Proper envelope handling
Future<Envelope> _handleMessage(Envelope envelope) async {
  try {
    // Validate payload
    final payload = envelope.payload;
    if (payload == null || payload.isEmpty) {
      return envelope.createErrorResponse(
        'InvalidPayload', 
        'Message payload is required'
      );
    }
    
    // Process message
    final result = await _processBusinessLogic(payload);
    
    // Return response with correlation ID preserved
    return envelope.createResponse(result);
    
  } catch (e, stackTrace) {
    // Log error with correlation ID
    log.e('Message handling failed', 
          error: e, 
          stackTrace: stackTrace,
          correlationId: envelope.correlationId);
    
    // Return error envelope
    return envelope.createErrorResponse(
      'ProcessingError',
      'Failed to process message: ${e.toString()}'
    );
  }
}
```

## 🎨 Modern Flutter Standards

### **Color and Styling**
```dart
// ❌ Deprecated - causes linter errors
color.withOpacity(0.5)

// ✅ Modern approach
color.withValues(alpha: 0.5)

// ✅ For multiple values
color.withValues(
  alpha: 0.8,
  red: 0.9,
  green: 0.7,
  blue: 0.6,
)
```

### **Widget Lifecycle Management**
```dart
// ✅ Proper resource disposal
class MyCellWidget extends StatefulWidget {
  @override
  State<MyCellWidget> createState() => _MyCellWidgetState();
}

class _MyCellWidgetState extends State<MyCellWidget> {
  late ScrollController _scrollController;
  late ValueNotifier<bool> _stateNotifier;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _stateNotifier = ValueNotifier(false);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _stateNotifier.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _stateNotifier,
      builder: (context, value, child) {
        return Container(/* ... */);
      },
    );
  }
}
```

### **State Management in CBS Cells**
```dart
// ✅ CBS-compliant state management
class DataDisplayCell implements Cell {
  final ValueNotifier<List<DataItem>> _dataNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  
  // Expose reactive state
  ValueNotifier<List<DataItem>> get dataNotifier => _dataNotifier;
  ValueNotifier<bool> get loadingNotifier => _loadingNotifier;
  
  @override
  Future<void> register(Bus bus) async {
    await bus.subscribe('cbs.data_display.load', _handleLoad);
    await bus.subscribe('cbs.data_display.update', _handleUpdate);
  }
  
  Future<Envelope> _handleLoad(Envelope envelope) async {
    _loadingNotifier.value = true;
    
    try {
      // Request data from storage cell via bus
      final response = await bus.request(Envelope.newRequest(
        service: 'data_store',
        verb: 'query',
        payload: envelope.payload,
      ));
      
      if (response.isSuccess) {
        _dataNotifier.value = response.payload['data'];
      }
      
      return envelope.createResponse({'loaded': response.isSuccess});
      
    } finally {
      _loadingNotifier.value = false;
    }
  }
  
  void dispose() {
    _dataNotifier.dispose();
    _loadingNotifier.dispose();
  }
}
```

## 🚨 Common Linter Issues and Fixes

### **Deprecated APIs**
```dart
// ❌ Deprecated APIs to avoid
color.withOpacity(0.5)              // Use withValues(alpha: 0.5)
ThemeData.copyWith()                // Use ThemeData() constructor
MediaQuery.of(context).size         // Use MediaQuery.sizeOf(context)
Scaffold.of(context)                // Use Scaffold.maybeOf(context)

// ✅ Modern replacements
color.withValues(alpha: 0.5)
ThemeData(/* specify all needed properties */)
MediaQuery.sizeOf(context)
Scaffold.maybeOf(context)
```

### **Null Safety**
```dart
// ✅ Proper null safety in CBS cells
class UserProfileCell implements Cell {
  String? _currentUserId;
  
  Future<Envelope> _handleGetProfile(Envelope envelope) async {
    final userId = envelope.payload?['user_id'] as String?;
    
    if (userId == null || userId.isEmpty) {
      return envelope.createErrorResponse(
        'MissingUserId',
        'user_id is required in payload'
      );
    }
    
    // Safe to use userId here
    final profile = await _fetchProfile(userId);
    return envelope.createResponse({'profile': profile?.toJson()});
  }
}
```

### **Widget Testing Standards**
```dart
// ✅ Proper widget testing for CBS cells
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Bus])
import 'my_cell_test.mocks.dart';

void main() {
  group('MyCellWidget', () {
    late MockBus mockBus;
    late MyCellCell cell;
    
    setUp(() {
      mockBus = MockBus();
      cell = MyCellCell();
    });
    
    tearDown(() {
      cell.dispose();
    });
    
    testWidgets('should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyCellWidget(cell: cell),
        ),
      );
      
      expect(find.text('Expected Text'), findsOneWidget);
    });
    
    test('should handle bus messages correctly', () async {
      final envelope = Envelope.newRequest(
        service: 'my_cell_name',
        verb: 'test',
        payload: {'test': 'data'},
      );
      
      final response = await cell.handleMessage(envelope);
      
      expect(response.isSuccess, isTrue);
      expect(response.payload['status'], equals('processed'));
    });
  });
}
```

## 📱 CBS-Specific Flutter Patterns

### **UI Cell Structure**
```dart
// ✅ Recommended UI cell structure
import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../utils/logger.dart';

/// UI Cell for [specific functionality]
class MyUICell implements Cell {
  final ValueNotifier<MyUIState> _stateNotifier = ValueNotifier(MyUIState.initial());
  
  @override
  String get id => 'my_ui_cell';
  
  @override
  List<String> get subjects => ['cbs.my_ui_cell.render', 'cbs.my_ui_cell.update'];
  
  @override
  Future<void> register(Bus bus) async {
    await bus.subscribe('cbs.my_ui_cell.render', _handleRender);
    await bus.subscribe('cbs.my_ui_cell.update', _handleUpdate);
  }
  
  // Public widget for use in other UI cells
  Widget buildWidget(BuildContext context) {
    return ValueListenableBuilder<MyUIState>(
      valueListenable: _stateNotifier,
      builder: (context, state, child) {
        return MyUIWidget(
          state: state,
          onAction: _handleUserAction,
        );
      },
    );
  }
  
  Future<Envelope> _handleRender(Envelope envelope) async {
    log.d('Rendering UI cell', correlationId: envelope.correlationId);
    
    // Update state based on envelope payload
    final newState = MyUIState.fromPayload(envelope.payload);
    _stateNotifier.value = newState;
    
    return envelope.createResponse({'rendered': true});
  }
  
  void _handleUserAction(String action, Map<String, dynamic> data) {
    // Publish user action to bus
    bus.publish(Envelope.newRequest(
      service: 'business_logic',
      verb: 'process_action',
      payload: {
        'action': action,
        'data': data,
        'source': id,
      },
    ));
  }
  
  void dispose() {
    _stateNotifier.dispose();
  }
}

/// State class for UI cell
@immutable
class MyUIState {
  final String title;
  final bool isLoading;
  final List<String> items;
  
  const MyUIState({
    required this.title,
    required this.isLoading,
    required this.items,
  });
  
  factory MyUIState.initial() => const MyUIState(
    title: '',
    isLoading: false,
    items: [],
  );
  
  factory MyUIState.fromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return MyUIState.initial();
    
    return MyUIState(
      title: payload['title'] as String? ?? '',
      isLoading: payload['loading'] as bool? ?? false,
      items: (payload['items'] as List?)?.cast<String>() ?? [],
    );
  }
  
  MyUIState copyWith({
    String? title,
    bool? isLoading,
    List<String>? items,
  }) {
    return MyUIState(
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
    );
  }
}
```

### **Logic Cell Structure**
```dart
// ✅ Recommended logic cell structure
import 'package:cbs_sdk/cbs_sdk.dart';
import '../utils/logger.dart';

/// Logic Cell for [specific business logic]
class MyLogicCell implements Cell {
  @override
  String get id => 'my_logic_cell';
  
  @override
  List<String> get subjects => [
    'cbs.my_logic_cell.process',
    'cbs.my_logic_cell.validate',
  ];
  
  @override
  Future<void> register(Bus bus) async {
    await bus.subscribe('cbs.my_logic_cell.process', _handleProcess);
    await bus.subscribe('cbs.my_logic_cell.validate', _handleValidate);
  }
  
  Future<Envelope> _handleProcess(Envelope envelope) async {
    final correlationId = envelope.correlationId;
    log.d('Processing business logic', correlationId: correlationId);
    
    try {
      // Extract and validate input
      final input = _validateInput(envelope.payload);
      
      // Perform business logic
      final result = await _performBusinessLogic(input);
      
      // Publish result to interested cells
      await bus.publish(Envelope.newRequest(
        service: 'data_store',
        verb: 'save',
        payload: result,
        correlationId: correlationId,
      ));
      
      return envelope.createResponse({
        'success': true,
        'result': result,
      });
      
    } catch (e, stackTrace) {
      log.e('Business logic processing failed',
            error: e,
            stackTrace: stackTrace,
            correlationId: correlationId);
      
      return envelope.createErrorResponse(
        'ProcessingError',
        'Failed to process: ${e.toString()}',
      );
    }
  }
  
  Map<String, dynamic> _validateInput(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) {
      throw ArgumentError('Payload is required');
    }
    
    // Perform validation logic
    return payload;
  }
  
  Future<Map<String, dynamic>> _performBusinessLogic(
    Map<String, dynamic> input,
  ) async {
    // Implement business logic here
    return {'processed': true, 'data': input};
  }
}
```

## 🔧 Development Tools Integration

### **Pubspec.yaml Standards**
```yaml
# ✅ Standard CBS cell pubspec.yaml
name: my_cell_name_cell
description: CBS cell for [specific functionality]
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'

dependencies:
  flutter:
    sdk: flutter
  cbs_sdk:
    path: ../../../../shared_cells/dart/cbs_sdk
  
  # Common dependencies for CBS cells
  uuid: ^4.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### **Import Organization**
```dart
// ✅ Proper import organization
// 1. Dart/Flutter imports
import 'dart:async';
import 'dart:convert';

// 2. Package imports  
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// 3. CBS SDK imports
import 'package:cbs_sdk/cbs_sdk.dart';

// 4. Local imports (relative)
import '../models/my_model.dart';
import '../services/my_service.dart';
import '../utils/logger.dart';
```

### **Logging Standards**
```dart
// ✅ CBS logging with correlation IDs
import '../utils/logger.dart';

class MyCell implements Cell {
  Future<Envelope> _handleMessage(Envelope envelope) async {
    final correlationId = envelope.correlationId;
    
    // Debug logging
    log.d('Processing message', 
          data: {'verb': envelope.verb}, 
          correlationId: correlationId);
    
    try {
      final result = await _processMessage(envelope.payload);
      
      // Info logging for important events
      log.i('Message processed successfully', 
            data: {'result_type': result.runtimeType.toString()},
            correlationId: correlationId);
      
      return envelope.createResponse(result);
      
    } catch (e, stackTrace) {
      // Error logging with full context
      log.e('Message processing failed',
            error: e,
            stackTrace: stackTrace,
            data: {
              'service': envelope.service,
              'verb': envelope.verb,
              'payload_keys': envelope.payload?.keys.toList(),
            },
            correlationId: correlationId);
      
      return envelope.createErrorResponse(
        'ProcessingError',
        e.toString(),
      );
    }
  }
}
```

## 🧪 Testing Standards

### **Unit Testing**
```dart
// ✅ Comprehensive unit testing
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Bus, ExternalService])
import 'my_cell_test.mocks.dart';

void main() {
  group('MyCell', () {
    late MyCell cell;
    late MockBus mockBus;
    
    setUp(() {
      mockBus = MockBus();
      cell = MyCell();
    });
    
    tearDown(() {
      cell.dispose();
    });
    
    group('Cell trait implementation', () {
      test('should have correct id', () {
        expect(cell.id, equals('my_cell'));
      });
      
      test('should have correct subjects', () {
        expect(cell.subjects, contains('cbs.my_cell.process'));
      });
      
      test('should register with bus', () async {
        await cell.register(mockBus);
        
        verify(mockBus.subscribe('cbs.my_cell.process', any)).called(1);
      });
    });
    
    group('Message handling', () {
      test('should process valid messages', () async {
        final envelope = Envelope.newRequest(
          service: 'my_cell',
          verb: 'process',
          payload: {'data': 'test'},
        );
        
        final response = await cell.handleMessage(envelope);
        
        expect(response.isSuccess, isTrue);
        expect(response.payload['status'], equals('processed'));
      });
      
      test('should handle invalid messages', () async {
        final envelope = Envelope.newRequest(
          service: 'my_cell',
          verb: 'process',
          payload: null,
        );
        
        final response = await cell.handleMessage(envelope);
        
        expect(response.isError, isTrue);
        expect(response.error?.code, equals('InvalidPayload'));
      });
    });
  });
}
```

### **Widget Testing**
```dart
// ✅ Widget testing for UI cells
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyUIWidget', () {
    testWidgets('should render with initial state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyUIWidget(
            initialData: 'test data',
            onAction: (action, data) {},
          ),
        ),
      );
      
      expect(find.text('test data'), findsOneWidget);
    });
    
    testWidgets('should handle user interactions', (tester) async {
      String? capturedAction;
      Map<String, dynamic>? capturedData;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MyUIWidget(
            onAction: (action, data) {
              capturedAction = action;
              capturedData = data;
            },
          ),
        ),
      );
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(capturedAction, equals('button_pressed'));
      expect(capturedData, isNotNull);
    });
  });
}
```

## 📦 Package Structure Standards

### **Cell Package Organization**
```
my_cell_name/
├── ai/
│   └── spec.md                 # Cell specification
├── lib/
│   ├── my_cell_name_cell.dart  # Main cell class
│   ├── models/                 # Data models
│   │   ├── my_model.dart
│   │   └── my_state.dart
│   ├── services/               # Business logic services
│   │   └── my_service.dart
│   ├── widgets/                # UI widgets (for UI cells)
│   │   ├── my_widget.dart
│   │   └── components/
│   ├── providers/              # Riverpod providers (if needed)
│   │   └── my_provider.dart
│   └── utils/                  # Cell-specific utilities
│       ├── logger.dart
│       └── validators.dart
├── test/
│   ├── my_cell_name_cell_test.dart      # Cell unit tests
│   ├── models/                          # Model tests
│   ├── services/                        # Service tests
│   ├── widgets/                         # Widget tests
│   └── integration_test.dart            # Bus integration tests
└── pubspec.yaml
```

### **File Naming Conventions**
```bash
# ✅ Consistent naming patterns
my_cell_name_cell.dart          # Main cell class
my_model.dart                   # Data models
my_service.dart                 # Business logic services
my_widget.dart                  # UI widgets
my_provider.dart                # State providers
my_cell_name_cell_test.dart     # Test files
```

## 🚀 Performance Standards

### **Efficient State Management**
```dart
// ✅ Efficient ValueNotifier usage
class EfficientCell implements Cell {
  final ValueNotifier<List<Item>> _itemsNotifier = ValueNotifier([]);
  
  // Only notify when actually changed
  void updateItems(List<Item> newItems) {
    if (_itemsNotifier.value.length != newItems.length ||
        !_itemsEqual(_itemsNotifier.value, newItems)) {
      _itemsNotifier.value = newItems;
    }
  }
  
  bool _itemsEqual(List<Item> a, List<Item> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
```

### **Memory Management**
```dart
// ✅ Proper resource cleanup
class ResourceManagedCell implements Cell {
  late Timer _periodicTimer;
  late StreamSubscription _subscription;
  
  @override
  Future<void> register(Bus bus) async {
    // Set up resources
    _periodicTimer = Timer.periodic(Duration(seconds: 30), _periodicUpdate);
    _subscription = someStream.listen(_handleStreamData);
    
    await bus.subscribe('cbs.my_cell.process', _handleProcess);
  }
  
  void dispose() {
    _periodicTimer.cancel();
    _subscription.cancel();
    _stateNotifier.dispose();
  }
}
```

## 🔧 Linter Configuration

### **analysis_options.yaml for CBS Cells**
```yaml
# Recommended linter rules for CBS cells
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - .dart_tool/**

linter:
  rules:
    # CBS-specific rules
    avoid_print: true                    # Use log.d/i/w/e instead
    prefer_const_constructors: true      # Performance
    prefer_const_literals_to_create_immutables: true
    
    # Modern Flutter rules
    use_colored_box: true
    use_decorated_box: true
    prefer_const_declarations: true
    
    # Code quality
    avoid_redundant_argument_values: true
    avoid_unnecessary_containers: true
    sized_box_for_whitespace: true
    
    # CBS compliance helpers
    avoid_classes_with_only_static_members: true  # Use functions instead
    prefer_function_declarations_over_variables: true
```

This comprehensive Dart/Flutter standard ensures CBS cells are modern, efficient, and lint-free while maintaining proper CBS compliance! 🧬✨
