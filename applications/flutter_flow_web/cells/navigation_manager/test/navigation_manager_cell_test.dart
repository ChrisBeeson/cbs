import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import '../lib/navigation_manager_cell.dart';

@GenerateMocks([BodyBus])
import 'navigation_manager_cell_test.mocks.dart';

void main() {
  group('NavigationManagerCell', () {
    late NavigationManagerCell cell;
    late MockBodyBus mockBus;

    setUp(() {
      cell = NavigationManagerCell();
      mockBus = MockBodyBus();
    });

    tearDown(() {
      cell.dispose();
    });

    test('should have correct id and subjects', () {
      expect(cell.id, 'navigation_manager');
      expect(cell.subjects, [
        'cbs.navigation.get_current',
        'cbs.navigation.set_screen',
        'cbs.navigation.get_screens',
      ]);
    });

    test('should register with bus', () async {
      await cell.register(mockBus);
      
      verify(mockBus.subscribe('cbs.navigation.get_current', any)).called(1);
      verify(mockBus.subscribe('cbs.navigation.set_screen', any)).called(1);
      verify(mockBus.subscribe('cbs.navigation.get_screens', any)).called(1);
    });

    group('get current screen', () {
      test('should return current screen state', () async {
        final envelope = Envelope(
          id: '1',
          service: 'navigation',
          verb: 'get_current',
          schema: 'navigation.get_current.v1',
          payload: {},
        );

        final result = await cell.handleGetCurrent(envelope);
        
        expect(result['status'], 'success');
        expect(result['current_screen'], 'screen_home'); // default
        expect(result, containsPair('params', isA<Map>()));
        expect(result, containsPair('history', isA<List>()));
      });
    });

    group('set screen', () {
      test('should set valid screen successfully', () async {
        final envelope = Envelope(
          id: '2',
          service: 'navigation',
          verb: 'set_screen',
          schema: 'navigation.set_screen.v1',
          payload: {
            'screen_id': 'screen_monitor',
            'params': {'test': 'value'},
          },
        );

        final result = await cell.handleSetScreen(envelope);
        
        expect(result['status'], 'success');
        expect(result['current_screen'], 'screen_monitor');
        expect(result['previous_screen'], 'screen_home');
      });

      test('should reject invalid screen', () async {
        final envelope = Envelope(
          id: '3',
          service: 'navigation',
          verb: 'set_screen',
          schema: 'navigation.set_screen.v1',
          payload: {
            'screen_id': 'invalid_screen',
          },
        );

        final result = await cell.handleSetScreen(envelope);
        
        expect(result['status'], 'error');
        expect(result['message'], contains('Invalid screen'));
      });

      test('should require screen_id', () async {
        final envelope = Envelope(
          id: '4',
          service: 'navigation',
          verb: 'set_screen',
          schema: 'navigation.set_screen.v1',
          payload: {},
        );

        final result = await cell.handleSetScreen(envelope);
        
        expect(result['status'], 'error');
        expect(result['message'], contains('screen_id is required'));
      });
    });

    group('get screens', () {
      test('should return available screens', () async {
        final envelope = Envelope(
          id: '5',
          service: 'navigation',
          verb: 'get_screens',
          schema: 'navigation.get_screens.v1',
          payload: {},
        );

        final result = await cell.handleGetScreens(envelope);
        
        expect(result['status'], 'success');
        expect(result['screens'], isA<Map>());
        expect(result['count'], isA<int>());
        expect(result['count'], greaterThan(0));
      });
    });

    test('should handle disposed state', () async {
      cell.dispose();
      
      final envelope = Envelope(
        id: '6',
        service: 'navigation',
        verb: 'get_current',
        schema: 'navigation.get_current.v1',
        payload: {},
      );

      final result = await cell.handleGetCurrent(envelope);
      
      expect(result['status'], 'error');
      expect(result['message'], contains('disposed'));
    });
  });
}