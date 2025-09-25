import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../lib/screen_home_cell.dart';

@GenerateMocks([BodyBus])
import 'screen_home_cell_test.mocks.dart';

void main() {
  group('ScreenHomeCell', () {
    late ScreenHomeCell cell;
    late MockBodyBus mockBus;

    setUp(() {
      cell = ScreenHomeCell();
      mockBus = MockBodyBus();
    });

    tearDown(() {
      cell.dispose();
    });

    test('should have correct id and subjects', () {
      expect(cell.id, 'screen_home');
      expect(cell.subjects, [
        'cbs.navigation.screen_changed',
        'cbs.flow_text.content_ready',
      ]);
    });

    test('should register with bus', () async {
      await cell.register(mockBus);
      
      verify(mockBus.subscribe('cbs.navigation.screen_changed', any)).called(1);
      verify(mockBus.subscribe('cbs.flow_text.content_ready', any)).called(1);
    });

    group('screen activation', () {
      test('should activate when screen changes to home', () async {
        final envelope = Envelope(
          id: '1',
          service: 'navigation',
          verb: 'screen_changed',
          schema: 'navigation.screen_changed.v1',
          payload: {
            'current_screen': 'screen_home',
            'previous_screen': 'screen_monitor',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        await cell.register(mockBus);
        final result = await cell.handleScreenChanged(envelope);
        
        expect(result['status'], 'handled');
        expect(result['screen_active'], true);
        expect(cell.isActive, true);
        verify(mockBus.request(any)).called(1); // content request
      });

      test('should deactivate when screen changes away from home', () async {
        final envelope = Envelope(
          id: '2',
          service: 'navigation',
          verb: 'screen_changed',
          schema: 'navigation.screen_changed.v1',
          payload: {
            'current_screen': 'screen_monitor',
            'previous_screen': 'screen_home',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        final result = await cell.handleScreenChanged(envelope);
        
        expect(result['status'], 'handled');
        expect(result['screen_active'], false);
        expect(cell.isActive, false);
      });
    });

    group('content handling', () {
      test('should handle flow text content ready', () async {
        final envelope = Envelope(
          id: '3',
          service: 'flow_text',
          verb: 'content_ready',
          schema: 'flow_text.content_ready.v1',
          payload: {
            'content': 'Test flow content',
          },
        );

        final result = await cell.handleContentReady(envelope);
        
        expect(result['status'], 'handled');
        expect(result['content_length'], 17);
        expect(cell.flowContent, 'Test flow content');
      });

      test('should handle empty content', () async {
        final envelope = Envelope(
          id: '4',
          service: 'flow_text',
          verb: 'content_ready',
          schema: 'flow_text.content_ready.v1',
          payload: {
            'content': null,
          },
        );

        final result = await cell.handleContentReady(envelope);
        
        expect(result['status'], 'handled');
        expect(result['content_length'], 0);
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
          'current_screen': 'screen_home',
        },
      );

      final result = await cell.handleScreenChanged(envelope);
      
      expect(result['status'], 'error');
      expect(result['message'], contains('disposed'));
    });

    test('should request content update', () async {
      await cell.register(mockBus);
      
      await cell.requestContentUpdate('New content');
      
      verify(mockBus.request(any)).called(1);
    });
  });
}