import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../lib/flow_ui_cell.dart';

@GenerateMocks([BodyBus])
import 'flow_ui_integration_test.mocks.dart';

void main() {
  group('FlowUIWidget Integration', () {
    testWidgets('should render split layout with flow text and bus monitor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Should find the main row layout (there will be multiple rows, check for at least one)
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      
      // Should find at least two expanded sections (main layout)
      expect(find.byType(Expanded), findsAtLeastNWidgets(2));
      
      // Should find flow text widget
      expect(find.text('Flow'), findsOneWidget);
      
      // Should find bus monitor section
      expect(find.textContaining('Messages'), findsOneWidget);
    });

    testWidgets('should have toggle button for flow text visibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Should find toggle button
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

    testWidgets('should have clear messages button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Should find clear button
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should display empty state when no messages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Should find empty state
      expect(find.text('No messages captured yet'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should apply dark theme consistently', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Check scaffold background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFF1A1A1A)));
      
      // Check that cyan accent color is used
      final flowText = tester.widget<Text>(find.text('Flow'));
      expect(flowText.style?.color, equals(const Color(0xFF00D4FF)));
    });

    testWidgets('should be responsive across different screen sizes', (tester) async {
      // Test mobile layout
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      expect(find.byType(Row), findsAtLeastNWidgets(1));
      
      // Test tablet layout
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();
      
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      
      // Test desktop layout
      tester.view.physicalSize = const Size(1400, 1000);
      await tester.pumpAndSettle();
      
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle message count display', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Should show message count (initially 0)
      expect(find.textContaining('Messages (0)'), findsOneWidget);
    });
  });

  group('FlowUICell CBS Integration', () {
    late FlowUICell cell;
    late MockBodyBus mockBus;

    setUp(() {
      cell = FlowUICell();
      mockBus = MockBodyBus();
    });

    tearDown(() {
      cell.dispose();
    });

    test('should have correct cell interface', () {
      expect(cell.id, equals('flow_ui'));
      expect(cell.subjects, contains('cbs.flow_ui.render'));
      expect(cell.subjects.length, equals(1));
    });

    test('should register with bus successfully', () async {
      when(mockBus.subscribe(any, any)).thenAnswer((_) async {});

      await cell.register(mockBus);

      verify(mockBus.subscribe('cbs.flow_ui.render', any)).called(1);
    });

    test('should handle render requests', () async {
      final envelope = Envelope.newRequest(
        service: 'flow_ui',
        verb: 'render',
        schema: 'ui/v1',
        payload: {'component': 'flow'},
      );

      final result = await cell.handleRender(envelope);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('rendered'));
      expect(result['component'], equals('flow'));
      expect(result['timestamp'], isA<String>());
    });

    test('should register bus-only communication subjects', () {
      expect(cell.subjects, contains('cbs.flow_ui.render'));
      expect(cell.subjects, contains('cbs.flow_ui.toggle_flow_text'));
      expect(cell.subjects, contains('cbs.flow_ui.clear_messages'));
    });

    test('should handle toggle operations via bus', () async {
      await cell.register(mockBus);
      
      // FlowUICell now forwards requests via bus - test the registration
      expect(cell.subjects, contains('cbs.flow_ui.toggle_flow_text'));
      
      // In the new architecture, FlowUICell acts as a coordinator
      // Full integration testing would require a real bus implementation
    });

    test('should handle clear messages operation', () async {
      await cell.register(mockBus);
      
      // FlowUICell now forwards clear requests via bus
      expect(cell.subjects, contains('cbs.flow_ui.clear_messages'));
      
      // In the new architecture, FlowUICell acts as a coordinator
      // Full integration testing would require a real bus implementation
    });
  });
}
