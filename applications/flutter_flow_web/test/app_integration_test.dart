import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import 'package:flow_ui_cell/flow_ui_cell.dart';
import 'package:bus_monitor_cell/bus_monitor_cell.dart';
import 'package:flow_text_cell/flow_text_widget.dart';
import '../lib/main.dart' as main_app;

@GenerateMocks([BodyBus])
import 'app_integration_test.mocks.dart';

void main() {
  group('Full Application Integration', () {
    testWidgets('should render complete application with all cells', (tester) async {
      await tester.pumpWidget(const main_app.FlowApp());

      // Should find main app components
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(FlowUIWidget), findsOneWidget);
      
      // Should find flow text
      expect(find.text('Flow'), findsOneWidget);
      
      // Should find bus monitor components
      expect(find.textContaining('Messages'), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
      
      // Should find toggle button
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      
      // Should find empty state
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No messages captured yet'), findsOneWidget);
    });

    testWidgets('should apply consistent dark theme', (tester) async {
      await tester.pumpWidget(const main_app.FlowApp());

      // Check MaterialApp theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.scaffoldBackgroundColor, equals(const Color(0xFF1A1A1A)));
      expect(materialApp.theme?.textTheme.displayLarge?.color, equals(const Color(0xFF00D4FF)));

      // Check scaffold background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFF1A1A1A)));
    });

    testWidgets('should handle flow text visibility toggle', (tester) async {
      await tester.pumpWidget(const main_app.FlowApp());

      // Initially flow text should be visible
      expect(find.text('Flow'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Flow text should be hidden
      expect(find.text('Flow'), findsNothing);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap again to show
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Flow text should be visible again
      expect(find.text('Flow'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should be responsive across different screen sizes', (tester) async {
      // Test mobile layout
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const main_app.FlowApp());
      await tester.pumpAndSettle();

      expect(find.text('Flow'), findsOneWidget);
      expect(find.textContaining('Messages'), findsOneWidget);

      // Test tablet layout
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      expect(find.text('Flow'), findsOneWidget);
      expect(find.textContaining('Messages'), findsOneWidget);

      // Test desktop layout
      tester.view.physicalSize = const Size(1400, 1000);
      await tester.pumpAndSettle();

      expect(find.text('Flow'), findsOneWidget);
      expect(find.textContaining('Messages'), findsOneWidget);
    });

    testWidgets('should have proper accessibility support', (tester) async {
      await tester.pumpWidget(const main_app.FlowApp());

      // Check semantic labels
      final flowText = tester.widget<Text>(find.text('Flow'));
      expect(flowText.semanticsLabel, isNotNull);
      expect(flowText.semanticsLabel, contains('Flow'));

      // Check button accessibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });
  });

  group('Cell Reusability and Independence', () {
    test('should create independent BusMonitorCell', () {
      final cell = BusMonitorCell();
      
      expect(cell.id, equals('bus_monitor'));
      expect(cell.subjects, contains('cbs.>'));
      expect(cell.messageCount, equals(0));
      
      cell.dispose();
    });

    test('should create independent FlowTextCell', () {
      final cell = FlowTextCell();
      
      expect(cell.isVisible, isTrue);
      
      cell.toggleVisibility();
      expect(cell.isVisible, isFalse);
      
      cell.setVisibility(true);
      expect(cell.isVisible, isTrue);
      
      cell.dispose();
    });

    test('should create independent FlowUICell', () {
      final cell = FlowUICell();
      
      expect(cell.id, equals('flow_ui'));
      expect(cell.subjects, contains('cbs.flow_ui.render'));
      expect(cell.busMonitorCell, isA<BusMonitorCell>());
      expect(cell.flowTextCell, isA<FlowTextCell>());
      
      cell.dispose();
    });

    testWidgets('should render FlowTextWidget independently', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlowTextWidget(
              visible: true,
              color: Colors.purple,
              fontSize: 48.0,
            ),
          ),
        ),
      );

      expect(find.text('Flow'), findsOneWidget);
      
      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.color, equals(Colors.purple));
      expect(textWidget.style?.fontSize, equals(48.0));
    });
  });

  group('CBS Integration', () {
    late MockBodyBus mockBus;

    setUp(() {
      mockBus = MockBodyBus();
    });

    test('should register FlowUICell with bus', () async {
      when(mockBus.subscribe(any, any)).thenAnswer((_) async {});

      final cell = FlowUICell();
      await cell.register(mockBus);

      // Should register both flow UI and bus monitor subscriptions
      verify(mockBus.subscribe('cbs.flow_ui.render', any)).called(1);
      verify(mockBus.subscribe('cbs.>', any)).called(1);

      cell.dispose();
    });

    test('should handle render requests', () async {
      final cell = FlowUICell();
      
      final envelope = Envelope.newRequest(
        service: 'flow_ui',
        verb: 'render',
        schema: 'ui/v1',
        payload: {'component': 'flow'},
      );

      final result = await cell.handleRender(envelope);

      expect(result['status'], equals('rendered'));
      expect(result['component'], equals('flow'));
      expect(result['timestamp'], isA<String>());

      cell.dispose();
    });

    test('should handle bus messages correctly', () async {
      final cell = BusMonitorCell();
      
      final envelope = Envelope.newRequest(
        service: 'test_service',
        verb: 'test_action',
        schema: 'test/v1',
        payload: {'data': 'test'},
      );

      final result = await cell.handleMessage(envelope);

      expect(result['status'], equals('captured'));
      expect(result['message_id'], equals(envelope.id));
      expect(result['timestamp'], isA<String>());
      expect(cell.messageCount, equals(1));

      cell.dispose();
    });
  });

  group('Performance and Memory Management', () {
    test('should dispose all resources properly', () {
      final cell = FlowUICell();
      
      // Verify initial state
      expect(cell.busMonitorCell.messageCount, equals(0));
      expect(cell.flowTextCell.isVisible, isTrue);
      
      // Add some messages
      final envelope = Envelope.newRequest(
        service: 'test',
        verb: 'test',
        schema: 'test/v1',
        payload: {},
      );
      cell.busMonitorCell.handleMessage(envelope);
      expect(cell.busMonitorCell.messageCount, equals(1));
      
      // Dispose and verify cleanup
      cell.dispose();
      
      // Should handle operations gracefully after disposal
      expect(() => cell.clearMessages(), returnsNormally);
      expect(() => cell.toggleFlowText(), returnsNormally);
    });

    testWidgets('should handle widget lifecycle properly', (tester) async {
      await tester.pumpWidget(const main_app.FlowApp());
      
      // Verify app renders correctly
      expect(find.byType(FlowUIWidget), findsOneWidget);
      expect(find.text('Flow'), findsOneWidget);
      
      // Dispose widget tree
      await tester.pumpWidget(Container());
      
      // Should not cause any errors
      expect(find.byType(FlowUIWidget), findsNothing);
    });

    test('should handle concurrent message processing', () async {
      final cell = BusMonitorCell();
      
      // Add multiple messages concurrently
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        final envelope = Envelope.newRequest(
          service: 'service_$i',
          verb: 'action_$i',
          schema: 'test/v1',
          payload: {'index': i},
        );
        futures.add(cell.handleMessage(envelope));
      }
      
      await Future.wait(futures);
      
      expect(cell.messageCount, equals(10));
      
      cell.dispose();
    });
  });
}
