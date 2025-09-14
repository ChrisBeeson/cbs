import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import '../lib/cbs_sdk.dart';

void main() {
  group('CBS Dart SDK Integration Tests', () {
    late NatsBus bus;

    setUpAll(() async {
      // Start NATS server for testing (if not already running)
      try {
        await Socket.connect('localhost', 4222);
      } catch (e) {
        // NATS not running, skip tests
        print('NATS server not running on localhost:4222, skipping integration tests');
        return;
      }
    });

    setUp(() async {
      if (await _isNatsRunning()) {
        bus = NatsBus(config: NatsBusConfig(url: 'nats://localhost:4222'));
        await bus.connect();
      }
    });

    tearDown(() async {
      if (await _isNatsRunning()) {
        await bus.close();
      }
    });

    test('should connect to NATS server', () async {
      if (!await _isNatsRunning()) return;
      
      expect(bus.isConnected, isTrue);
    });

    test('should create valid CBS envelope', () {
      final envelope = Envelope.newRequest(
        service: 'test',
        verb: 'echo',
        schema: 'demo/v1/Test',
        payload: {'message': 'hello'},
      );

      expect(envelope.id, isNotEmpty);
      expect(envelope.service, equals('test'));
      expect(envelope.verb, equals('echo'));
      expect(envelope.schema, equals('demo/v1/Test'));
      expect(envelope.payload, equals({'message': 'hello'}));
      expect(envelope.error, isNull);
      expect(envelope.subject, equals('cbs.test.echo'));
    });

    test('should create error envelope', () {
      final error = ErrorDetails(
        code: 'BadRequest',
        message: 'Invalid input',
        details: {'field': 'name'},
      );
      
      final envelope = Envelope.newError(
        requestId: 'test-id',
        service: 'test',
        verb: 'validate',
        schema: 'demo/v1/Error',
        error: error,
      );

      expect(envelope.id, equals('test-id'));
      expect(envelope.isError, isTrue);
      expect(envelope.error?.code, equals('BadRequest'));
      expect(envelope.error?.message, equals('Invalid input'));
      expect(envelope.payload, isNull);
    });

    test('should serialize and deserialize envelope to/from JSON', () {
      final original = Envelope.newRequest(
        service: 'test',
        verb: 'echo',
        schema: 'demo/v1/Test',
        payload: {'message': 'hello', 'count': 42},
      );

      final json = jsonEncode(original.toJson());
      final decoded = Envelope.fromJson(jsonDecode(json));

      expect(decoded.id, equals(original.id));
      expect(decoded.service, equals(original.service));
      expect(decoded.verb, equals(original.verb));
      expect(decoded.schema, equals(original.schema));
      expect(decoded.payload, equals(original.payload));
      expect(decoded.error, isNull);
    });

    test('should send request and receive response via NATS', () async {
      if (!await _isNatsRunning()) return;

      // Set up echo handler
      await bus.subscribe('cbs.test.echo', (envelope) async {
        return envelope.payload ?? {};
      });

      // Give subscription time to register
      await Future.delayed(Duration(milliseconds: 100));

      final request = Envelope.newRequest(
        service: 'test',
        verb: 'echo',
        schema: 'demo/v1/Test',
        payload: {'message': 'hello world'},
      );

      final response = await bus.request(request);
      expect(response['message'], equals('hello world'));
    });

    test('should handle request timeout when no subscribers', () async {
      if (!await _isNatsRunning()) return;

      final request = Envelope.newRequest(
        service: 'nonexistent',
        verb: 'action',
        schema: 'demo/v1/Test',
        payload: {},
      );

      expect(
        () => bus.request(request),
        throwsA(isA<BusError>()),
      );
    });

    test('should handle error responses', () async {
      if (!await _isNatsRunning()) return;

      // Set up error handler
      await bus.subscribe('cbs.test.error', (envelope) async {
        throw BusError.badRequest('Invalid input');
      });

      await Future.delayed(Duration(milliseconds: 100));

      final request = Envelope.newRequest(
        service: 'test',
        verb: 'error',
        schema: 'demo/v1/Test',
        payload: {},
      );

      expect(
        () => bus.request(request),
        throwsA(isA<BusError>()),
      );
    });

    test('should implement Cell trait correctly', () async {
      if (!await _isNatsRunning()) return;

      final testCell = TestCell();
      await testCell.register(bus);

      expect(testCell.id, equals('test_cell'));
      expect(testCell.subjects, contains('cbs.test.ping'));

      // Test the registered handler
      final request = Envelope.newRequest(
        service: 'test',
        verb: 'ping',
        schema: 'demo/v1/Ping',
        payload: {'message': 'ping'},
      );

      await Future.delayed(Duration(milliseconds: 100));
      final response = await bus.request(request);
      expect(response['message'], equals('pong'));
    });
  });
}

/// Test cell implementation
class TestCell implements Cell {
  @override
  String get id => 'test_cell';

  @override
  List<String> get subjects => ['cbs.test.ping'];

  @override
  Future<void> register(BodyBus bus) async {
    await bus.subscribe('cbs.test.ping', _handlePing);
  }

  Future<Map<String, dynamic>> _handlePing(Envelope envelope) async {
    return {'message': 'pong'};
  }
}

/// Helper to check if NATS is running
Future<bool> _isNatsRunning() async {
  try {
    final socket = await Socket.connect('localhost', 4222);
    await socket.close();
    return true;
  } catch (e) {
    return false;
  }
}
