import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../lib/bus_monitor_cell.dart';

@GenerateMocks([BodyBus])
import 'bus_monitor_cell_test.mocks.dart';

void main() {
  group('BusMonitorCell', () {
    late BusMonitorCell cell;
    late MockBodyBus mockBus;

    setUp(() {
      cell = BusMonitorCell();
      mockBus = MockBodyBus();
    });

    tearDown(() {
      cell.dispose();
    });

    group('Cell Interface', () {
      test('should have correct id', () {
        expect(cell.id, equals('bus_monitor'));
      });

      test('should have wildcard subject subscription', () {
        expect(cell.subjects, contains('cbs.>'));
        expect(cell.subjects, contains('cbs.bus_monitor.clear'));
        expect(cell.subjects.length, equals(2));
      });

      test('should register with bus successfully', () async {
        when(mockBus.subscribe(any, any)).thenAnswer((_) async {});

        await cell.register(mockBus);

        verify(mockBus.subscribe('cbs.>', any)).called(1);
        verify(mockBus.subscribe('cbs.bus_monitor.clear', any)).called(1);
      });
    });

    group('Message Handling', () {
      test('should drop oldest when exceeding 500 messages', () async {
        // Seed 500
        for (int i = 0; i < 500; i++) {
          final env = Envelope.newRequest(
            service: 'svc',
            verb: 'v$i',
            schema: 'svc/v1/Type',
            payload: {'i': i},
          );
          await cell.handleMessage(env);
        }
        expect(cell.messages.value.length, 500);

        // Add 10 more
        for (int i = 500; i < 510; i++) {
          final env = Envelope.newRequest(
            service: 'svc',
            verb: 'v$i',
            schema: 'svc/v1/Type',
            payload: {'i': i},
          );
          await cell.handleMessage(env);
        }

        expect(cell.messages.value.length, 500);
        // Oldest should have verb v10 now (first 10 dropped)
        expect(cell.messages.value.first.envelope.verb, 'v10');
      });
      test('should capture and store bus messages', () async {
        final envelope = Envelope.newRequest(
          service: 'test_service',
          verb: 'test_action',
          schema: 'test/v1',
          payload: {'data': 'test'},
        );

        await cell.handleMessage(envelope);

        expect(cell.messages.value, hasLength(1));
        expect(cell.messages.value.first.envelope, equals(envelope));
        expect(cell.messages.value.first.timestamp, isA<DateTime>());
      });

      test('should handle multiple messages in order', () async {
        final envelope1 = Envelope.newRequest(
          service: 'service1',
          verb: 'action1',
          schema: 'test/v1',
          payload: {'data': 'first'},
        );
        final envelope2 = Envelope.newRequest(
          service: 'service2',
          verb: 'action2',
          schema: 'test/v1',
          payload: {'data': 'second'},
        );

        await cell.handleMessage(envelope1);
        await cell.handleMessage(envelope2);

        expect(cell.messages.value, hasLength(2));
        expect(cell.messages.value[0].envelope.service, equals('service1'));
        expect(cell.messages.value[1].envelope.service, equals('service2'));
      });

      test('should handle error envelopes', () async {
        final errorEnvelope = Envelope.newError(
          requestId: 'test-id',
          service: 'error_service',
          verb: 'error_action',
          schema: 'error/v1',
          error: ErrorDetails.internal('Test error'),
        );

        await cell.handleMessage(errorEnvelope);

        expect(cell.messages.value, hasLength(1));
        expect(cell.messages.value.first.envelope.isError, isTrue);
        expect(cell.messages.value.first.envelope.error?.message, equals('Test error'));
      });

      test('should compute channel, payloadType, description and timestamp format', () async {
        final env = Envelope.newRequest(
          service: 'greeter',
          verb: 'say_hello',
          schema: 'greeter/v1/Name',
          payload: {'name': 'A'},
        );
        await cell.handleMessage(env);
        final msg = cell.messages.value.last;
        expect(msg.channel, 'cbs.greeter.say_hello');
        expect(msg.payloadType, 'Name');
        // Description registry has greeter.say_hello
        expect(msg.description.isNotEmpty, isTrue);
        expect(
          RegExp(r'^\d{2}:\d{2}:\d{2}\.\d{3}\$').hasMatch(msg.formattedTimestamp),
          isTrue,
        );
      });
    });

    group('Message Management', () {
      test('should clear all messages', () async {
        final envelope = Envelope.newRequest(
          service: 'test',
          verb: 'test',
          schema: 'test/v1',
          payload: {},
        );

        await cell.handleMessage(envelope);
        expect(cell.messages.value, hasLength(1));

        cell.clearMessages();
        expect(cell.messages.value, isEmpty);
      });

      test('should maintain message count', () async {
        expect(cell.messageCount, equals(0));

        final envelope = Envelope.newRequest(
          service: 'test',
          verb: 'test',
          schema: 'test/v1',
          payload: {},
        );

        await cell.handleMessage(envelope);
        expect(cell.messageCount, equals(1));

        await cell.handleMessage(envelope);
        expect(cell.messageCount, equals(2));

        cell.clearMessages();
        expect(cell.messageCount, equals(0));
      });

      test('should clear on cbs.bus_monitor.clear subject', () async {
        when(mockBus.subscribe(any, any)).thenAnswer((invocation) async {
          final subject = invocation.positionalArguments[0] as String;
          final handler = invocation.positionalArguments[1] as MessageHandler;
          if (subject == 'cbs.bus_monitor.clear') {
            // Simulate clear command
            final env = Envelope.newRequest(
              service: 'bus_monitor',
              verb: 'clear',
              schema: 'bus_monitor/v1/Clear',
              payload: {},
            );
            await handler(env);
          }
        });

        // Register to attach handler
        await cell.register(mockBus);

        // Seed
        final envelope = Envelope.newRequest(
          service: 'test',
          verb: 'test',
          schema: 'test/v1',
          payload: {},
        );
        await cell.handleMessage(envelope);
        expect(cell.messages.value, isNotEmpty);

        // Triggered by subscription mock above, buffer should be cleared
        expect(cell.messages.value, isEmpty);
      });
    });

    group('State Management', () {
      test('should notify listeners when messages change', () async {
        bool notified = false;
        cell.messages.addListener(() {
          notified = true;
        });

        final envelope = Envelope.newRequest(
          service: 'test',
          verb: 'test',
          schema: 'test/v1',
          payload: {},
        );

        await cell.handleMessage(envelope);
        expect(notified, isTrue);
      });

      test('should notify listeners when messages cleared', () {
        bool notified = false;
        cell.messages.addListener(() {
          notified = true;
        });

        cell.clearMessages();
        expect(notified, isTrue);
      });
    });

    group('Resource Management', () {
      test('should dispose resources properly', () {
        // Create a new cell for this test to avoid affecting other tests
        final testCell = BusMonitorCell();
        
        // Add a listener to verify disposal (no-op capture)
        testCell.messages.addListener(() {});

        // Dispose the cell
        testCell.dispose();

        // Try to trigger a notification - should not call listener
        // Note: This is a basic test - in real scenarios disposal prevents further operations
        expect(() => testCell.clearMessages(), returnsNormally);
      });
    });
  });

  group('BusMessage', () {
    test('should create message with timestamp and envelope', () {
      final envelope = Envelope.newRequest(
        service: 'test',
        verb: 'test',
        schema: 'test/v1',
        payload: {},
      );

      final message = BusMessage(
        timestamp: DateTime.now(),
        envelope: envelope,
      );

      expect(message.envelope, equals(envelope));
      expect(message.timestamp, isA<DateTime>());
    });

    test('should determine message type correctly', () {
      final uiEnvelope = Envelope.newRequest(
        service: 'ui_service',
        verb: 'render',
        schema: 'ui/v1',
        payload: {},
      );
      final logicEnvelope = Envelope.newRequest(
        service: 'logic_service',
        verb: 'process',
        schema: 'logic/v1',
        payload: {},
      );
      final errorEnvelope = Envelope.newError(
        requestId: 'test',
        service: 'any_service',
        verb: 'any_verb',
        schema: 'any/v1',
        error: ErrorDetails.internal('Test error'),
      );

      final uiMessage = BusMessage(timestamp: DateTime.now(), envelope: uiEnvelope);
      final logicMessage = BusMessage(timestamp: DateTime.now(), envelope: logicEnvelope);
      final errorMessage = BusMessage(timestamp: DateTime.now(), envelope: errorEnvelope);

      expect(uiMessage.messageType, equals(BusMessageType.ui));
      expect(logicMessage.messageType, equals(BusMessageType.logic));
      expect(errorMessage.messageType, equals(BusMessageType.error));
    });

    test('should parse schema info and expose channel/description', () async {
      final env = Envelope.newRequest(
        service: 'flow_ui',
        verb: 'toggle',
        schema: 'flow_ui/v1/Toggle',
        payload: {},
      );
      final message = BusMessage(timestamp: DateTime.now(), envelope: env);
      expect(message.channel, 'cbs.flow_ui.toggle');
      expect(message.payloadType, 'Toggle');
      expect(message.description.isNotEmpty, isTrue);
    });
  });
}
