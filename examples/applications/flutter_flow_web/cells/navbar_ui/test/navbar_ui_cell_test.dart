import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../lib/navbar_ui_cell.dart';

@GenerateMocks([BodyBus])
import 'navbar_ui_cell_test.mocks.dart';

void main() {
  group('NavbarUICell', () {
    late NavbarUICell cell;
    late MockBodyBus mockBus;

    setUp(() {
      cell = NavbarUICell();
      mockBus = MockBodyBus();
    });

    tearDown(() {
      cell.dispose();
    });

    test('should have correct id and subjects', () {
      expect(cell.id, 'navbar_ui');
      expect(cell.subjects, [
        'cbs.navigation.current_response',
        'cbs.navigation.screen_changed',
      ]);
    });

    test('should register with bus', () async {
      await cell.register(mockBus);
      
      verify(mockBus.subscribe('cbs.navigation.current_response', any)).called(1);
      verify(mockBus.subscribe('cbs.navigation.screen_changed', any)).called(1);
      verify(mockBus.request(any)).called(1); // get_current request
    });

    group('screen change handling', () {
      test('should handle screen changed notification', () async {
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

        final result = await cell.handleScreenChanged(envelope);
        
        expect(result['status'], 'handled');
        expect(result['current_screen'], 'screen_monitor');
        expect(cell.currentScreen, 'screen_monitor');
      });

      test('should handle current response', () async {
        final envelope = Envelope(
          id: '2',
          service: 'navigation',
          verb: 'current_response',
          schema: 'navigation.current_response.v1',
          payload: {
            'current_screen': 'screen_home',
            'params': {},
            'history': [],
          },
        );

        final result = await cell.handleCurrentResponse(envelope);
        
        expect(result['status'], 'handled');
        expect(result['current_screen'], 'screen_home');
        expect(cell.currentScreen, 'screen_home');
      });
    });

    test('should handle disposed state', () async {
      cell.dispose();
      
      final envelope = Envelope(
        id: '3',
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

    test('should request screen change', () async {
      await cell.register(mockBus);
      
      await cell.requestScreenChange('screen_monitor', params: {'test': 'value'});
      
      verify(mockBus.request(any)).called(2); // get_current + set_screen
    });
  });
}