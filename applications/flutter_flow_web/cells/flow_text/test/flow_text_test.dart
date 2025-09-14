import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/flow_text_widget.dart';

void main() {
  group('FlowTextWidget', () {
    testWidgets('should render Flow text when visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      expect(find.text('Flow'), findsOneWidget);
    });

    testWidgets('should not render Flow text when not visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: false),
        ),
      );

      expect(find.text('Flow'), findsNothing);
    });

    testWidgets('should use default cyan color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.color, equals(const Color(0xFF00D4FF)));
    });

    testWidgets('should use custom color when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(
            visible: true,
            color: Colors.purple,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.color, equals(Colors.purple));
    });

    testWidgets('should use custom font size when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(
            visible: true,
            fontSize: 100.0,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.fontSize, equals(100.0));
    });

    testWidgets('should apply letter spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(
            visible: true,
            letterSpacing: 8.0,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.letterSpacing, equals(8.0));
    });

    testWidgets('should have glow shadow effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.shadows, isNotEmpty);
      expect(textWidget.style?.shadows?.first.blurRadius, equals(20.0));
    });

    testWidgets('should display gradient underline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should be responsive on mobile screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.fontSize, equals(48.0)); // Mobile size
    });

    testWidgets('should be responsive on tablet screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.fontSize, equals(72.0)); // Tablet size
    });

    testWidgets('should be responsive on desktop screen', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: FlowTextWidget(visible: true),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Flow'));
      expect(textWidget.style?.fontSize, equals(96.0)); // Desktop size
    });
  });

  group('FlowTextCell', () {
    late FlowTextCell cell;

    setUp(() {
      cell = FlowTextCell();
    });

    tearDown(() {
      cell.dispose();
    });

    test('should start with visible state', () {
      expect(cell.isVisible, isTrue);
    });

    test('should toggle visibility', () {
      expect(cell.isVisible, isTrue);
      
      cell.toggleVisibility();
      expect(cell.isVisible, isFalse);
      
      cell.toggleVisibility();
      expect(cell.isVisible, isTrue);
    });

    test('should set explicit visibility', () {
      cell.setVisibility(false);
      expect(cell.isVisible, isFalse);
      
      cell.setVisibility(true);
      expect(cell.isVisible, isTrue);
      
      cell.setVisibility(true); // Should remain true
      expect(cell.isVisible, isTrue);
    });

    test('should notify listeners when visibility changes', () {
      bool notified = false;
      cell.visibilityNotifier.addListener(() {
        notified = true;
      });

      cell.toggleVisibility();
      expect(notified, isTrue);
    });

    test('should not notify listeners when setting same visibility', () {
      bool notified = false;
      cell.visibilityNotifier.addListener(() {
        notified = true;
      });

      cell.setVisibility(true); // Already true
      expect(notified, isFalse);
    });

    test('should dispose resources properly', () {
      // Create a new cell for disposal test
      final testCell = FlowTextCell();
      
      bool listenerCalled = false;
      testCell.visibilityNotifier.addListener(() {
        listenerCalled = true;
      });

      testCell.dispose();
      
      // Verify disposal doesn't cause exceptions
      expect(() => testCell.toggleVisibility(), returnsNormally);
    });
  });
}
