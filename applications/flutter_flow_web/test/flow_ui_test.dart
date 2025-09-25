import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flow_ui_cell/flow_ui_cell.dart';

void main() {
  group('Flow UI Cell Tests', () {
    testWidgets('should render "Flow" text centered on screen', (WidgetTester tester) async {
      // Build the Flow UI widget
      await tester.pumpWidget(
        MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Verify that "Flow" text is displayed
      expect(find.text('Flow'), findsOneWidget);

      // Verify the text is centered
      final flowTextFinder = find.text('Flow');
      final centerFinder = find.byType(Center);
      
      expect(centerFinder, findsOneWidget);
      expect(find.descendant(of: centerFinder, matching: flowTextFinder), findsOneWidget);
    });

    testWidgets('should have modern styling with large font and primary color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      
      // Check that the text has custom styling
      expect(textWidget.style, isNotNull);
      expect(textWidget.style!.fontSize, greaterThan(32.0));
      expect(textWidget.style!.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should be responsive and maintain center alignment', (WidgetTester tester) async {
      // Test different screen sizes
      await tester.binding.setSurfaceSize(Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      expect(find.text('Flow'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);

      // Test mobile size
      await tester.binding.setSurfaceSize(Size(375, 667));
      await tester.pumpAndSettle();

      expect(find.text('Flow'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should have proper accessibility support', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Verify semantics are properly set
      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.semanticsLabel, isNotNull);
    });

    test('FlowUICell should implement Cell interface correctly', () {
      final cell = FlowUICell();
      
      expect(cell.id, equals('flow_ui'));
      expect(cell.subjects, contains('cbs.flow_ui.render'));
      expect(cell.subjects, hasLength(1));
    });

    test('FlowUICell should handle render requests', () async {
      final cell = FlowUICell();
      
      // Mock a render request envelope
      final mockEnvelope = MockEnvelope(
        id: 'test-id',
        service: 'flow_ui',
        verb: 'render',
        schema: 'flutter/v1/RenderRequest',
        payload: {'component': 'flow'},
      );

      final result = await cell.handleRender(mockEnvelope);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('rendered'));
      expect(result['component'], equals('flow'));
    });
  });
}

/// Mock envelope for testing
class MockEnvelope {
  final String id;
  final String service;
  final String verb;
  final String schema;
  final Map<String, dynamic>? payload;

  MockEnvelope({
    required this.id,
    required this.service,
    required this.verb,
    required this.schema,
    this.payload,
  });
}
