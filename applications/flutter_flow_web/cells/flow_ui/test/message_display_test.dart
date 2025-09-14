import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import 'package:bus_monitor_cell/bus_monitor_cell.dart';
import '../lib/flow_ui_cell.dart';

void main() {
  group('Message Display Features', () {
    testWidgets('should display basic UI structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Should find the basic UI elements
      expect(find.text('Flow'), findsOneWidget);
      expect(find.textContaining('Messages'), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should show message count in header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      // Initially should show 0 messages
      expect(find.textContaining('Messages (0)'), findsOneWidget);
    });

    testWidgets('should show empty state when no messages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlowUIWidget(),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No messages captured yet'), findsOneWidget);
      expect(find.text('Bus messages will appear here in real-time'), findsOneWidget);
    });
  });

  group('BusMessage Color Coding', () {
    test('should assign correct colors to different message types', () {
      // Test UI message
      final uiEnvelope = Envelope.newRequest(
        service: 'ui_service',
        verb: 'render',
        schema: 'ui/v1',
        payload: {},
      );
      final uiMessage = BusMessage(timestamp: DateTime.now(), envelope: uiEnvelope);
      expect(uiMessage.messageType, equals(BusMessageType.ui));
      expect(uiMessage.displayColor, equals(Colors.blue));

      // Test logic message
      final logicEnvelope = Envelope.newRequest(
        service: 'logic_service',
        verb: 'process',
        schema: 'logic/v1',
        payload: {},
      );
      final logicMessage = BusMessage(timestamp: DateTime.now(), envelope: logicEnvelope);
      expect(logicMessage.messageType, equals(BusMessageType.logic));
      expect(logicMessage.displayColor, equals(Colors.green));

      // Test error message
      final errorEnvelope = Envelope.newError(
        requestId: 'test',
        service: 'any_service',
        verb: 'any_verb',
        schema: 'any/v1',
        error: ErrorDetails.internal('Test error'),
      );
      final errorMessage = BusMessage(timestamp: DateTime.now(), envelope: errorEnvelope);
      expect(errorMessage.messageType, equals(BusMessageType.error));
      expect(errorMessage.displayColor, equals(Colors.red));

      // Test other message
      final otherEnvelope = Envelope.newRequest(
        service: 'other_service',
        verb: 'other_action',
        schema: 'other/v1',
        payload: {},
      );
      final otherMessage = BusMessage(timestamp: DateTime.now(), envelope: otherEnvelope);
      expect(otherMessage.messageType, equals(BusMessageType.other));
      expect(otherMessage.displayColor, equals(Colors.white70));
    });

    test('should format timestamps correctly', () {
      final timestamp = DateTime(2025, 9, 15, 10, 30, 45, 123);
      final envelope = Envelope.newRequest(
        service: 'test',
        verb: 'test',
        schema: 'test/v1',
        payload: {},
      );
      final message = BusMessage(timestamp: timestamp, envelope: envelope);
      
      expect(message.formattedTimestamp, equals('10:30:45.123'));
    });
  });

  group('Resource Management', () {
    test('should dispose resources properly', () {
      final cell = FlowUICell();
      
      // Verify initial state
      expect(cell.busMonitorCell.messageCount, equals(0));
      expect(cell.flowTextCell.isVisible, isTrue);
      
      // Dispose and verify
      cell.dispose();
      
      // Should handle operations gracefully after disposal
      expect(() => cell.clearMessages(), returnsNormally);
      expect(() => cell.toggleFlowText(), returnsNormally);
    });
  });
}
