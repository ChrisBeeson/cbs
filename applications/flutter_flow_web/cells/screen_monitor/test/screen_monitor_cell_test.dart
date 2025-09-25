import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../lib/screen_monitor_cell.dart';

@GenerateMocks([BodyBus])
import 'screen_monitor_cell_test.mocks.dart';

void main() {
  group('ScreenMonitorCell', () {
    late ScreenMonitorCell cell;
    late MockBodyBus mockBus;

    setUp(() {
      cell = ScreenMonitorCell();
      mockBus = MockBodyBus();
    });

    tearDown(() {
      cell.dispose();
    });

    test('should have correct id and subjects', () {
      expect(cell.id, 'screen_monitor');
      expect(cell.subjects, [
        'cbs.navigation.screen_changed',
        'cbs.bus_monitor.messages_updated',
      ]);
    });

    test('should register with bus', () async {
      await cell.register(mockBus);
      
      verify(mockBus.subscribe('cbs.navigation.screen_changed', any)).called(1);
      verify(mockBus.subscribe('cbs.bus_monitor.messages_updated', any)).called(1);
    });

    group('screen activation', () {
      test('should activate when screen changes to monitor', () async {
        final envelope = Envelope(
          id: '1',
          service: 'navigation',
          verb: 'screen_changed',
          schema: 'navigation.screen_changed.v1',
          payload: {
            'current_screen': 'screen_monitor',
            'previous_screen': 'screen_home',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        await cell.register(mockBus);
        final result = await cell.handleScreenChanged(envelope);
        
        expect(result['status'], 'handled');
        expect(result['screen_active'], true);
        expect(cell.isActive, true);
        verify(mockBus.request(any)).called(1); // message request
      });

      test('should deactivate when screen changes away from monitor', () async {
        final envelope = Envelope(
          id: '2',
          service: 'navigation',
          verb: 'screen_changed',
          schema: 'navigation.screen_changed.v1',
          payload: {
            'current_screen': 'screen_home',
            'previous_screen': 'screen_monitor',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        final result = await cell.handleScreenChanged(envelope);
        
        expect(result['status'], 'handled');
        expect(result['screen_active'], false);
        expect(cell.isActive, false);
      });
    });

    group('message handling', () {
      test('should handle messages updated', () async {
        final envelope = Envelope(
          id: '3',
          service: 'bus_monitor',
          verb: 'messages_updated',
          schema: 'bus_monitor.messages_updated.v1',
          payload: {
            'messages': [
              {
                'subject': 'cbs.test.message',
                'service': 'test',
                'verb': 'message',
                'timestamp': DateTime.now().toIso8601String(),
                'payload': {'test': 'data'},
              }
            ],
          },
        );

        final result = await cell.handleMessagesUpdated(envelope);
        
        expect(result['status'], 'handled');
        expect(result['message_count'], 1);
        expect(cell.messages.length, 1);
      });

      test('should handle empty messages list', () async {
        final envelope = Envelope(
          id: '4',
          service: 'bus_monitor',
          verb: 'messages_updated',
          schema: 'bus_monitor.messages_updated.v1',
          payload: {
            'messages': [],
          },
        );

        final result = await cell.handleMessagesUpdated(envelope);
        
        expect(result['status'], 'handled');
        expect(result['message_count'], 0);
        expect(cell.messages.length, 0);
      });

      test('should add single message', () {
        final message = {
          'subject': 'cbs.test.single',
          'service': 'test',
          'verb': 'single',
          'timestamp': DateTime.now().toIso8601String(),
          'payload': {'test': 'single'},
        };

        cell.addMessage(message);
        
        expect(cell.messages.length, 1);
        expect(cell.messages.first['subject'], 'cbs.test.single');
      });
    });

    test('should handle disposed state', () async {
      cell.dispose();
      
      final envelope = Envelope(
        id: '5',
        service: 'navigation',
        verb: 'screen_changed',
        schema: 'navigation.screen_changed.v1',
        payload: {
          'current_screen': 'screen_monitor',
        },
      );

      final result = await cell.handleScreenChanged(envelope);
      
      expect(result['status'], 'error');
      expect(result['message'], contains('disposed'));
    });

    test('should request clear messages', () async {
      await cell.register(mockBus);
      
      await cell.requestClearMessages();
      
      verify(mockBus.request(any)).called(1);
    });
  });
}