import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'bus.dart';
import 'envelope.dart';
import 'errors.dart';

/// Configuration for NATS bus connection and behavior
class NatsBusConfig {
  final String url;
  final Duration requestTimeout;
  final Duration connectionTimeout;
  final int maxReconnectAttempts;
  final Duration reconnectDelay;

  const NatsBusConfig({
    this.url = 'nats://localhost:4222',
    this.requestTimeout = const Duration(seconds: 5),
    this.connectionTimeout = const Duration(seconds: 10),
    this.maxReconnectAttempts = 10,
    this.reconnectDelay = const Duration(milliseconds: 500),
  });
}

/// NATS-based implementation of the BodyBus trait
class NatsBus implements BodyBus {
  final NatsBusConfig config;
  Socket? _socket;
  final Map<String, MessageHandler> _handlers = {};
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};
  StreamSubscription<Uint8List>? _subscription;
  bool _isConnected = false;
  String _buffer = '';
  int _nextSid = 1;
  final Map<String, int> _subscriptions = {};

  NatsBus({required this.config});

  @override
  bool get isConnected => _isConnected;

  /// Connect to NATS server
  Future<void> connect() async {
    try {
      final uri = Uri.parse(config.url);
      _socket = await Socket.connect(
        uri.host,
        uri.port,
        timeout: config.connectionTimeout,
      );

      _isConnected = true;
      _setupSocketListener();
      
      // Send CONNECT message
      await _sendConnect();
      
      // Send PING to verify connection
      await _sendPing();
    } catch (e) {
      throw ConnectionError('Failed to connect to NATS: $e');
    }
  }

  void _setupSocketListener() {
    _subscription = _socket?.listen(
      _handleData,
      onError: (error) {
        _isConnected = false;
        throw ConnectionError('Socket error: $error');
      },
      onDone: () {
        _isConnected = false;
      },
    );
  }

  void _handleData(Uint8List data) {
    _buffer += utf8.decode(data);
    _processBuffer();
  }

  void _processBuffer() {
    while (_buffer.contains('\r\n')) {
      final lineEnd = _buffer.indexOf('\r\n');
      final line = _buffer.substring(0, lineEnd);
      _buffer = _buffer.substring(lineEnd + 2);
      
      _processLine(line);
    }
  }

  void _processLine(String line) {
    final parts = line.split(' ');
    if (parts.isEmpty) return;

    switch (parts[0]) {
      case 'MSG':
        _handleMessage(line);
        break;
      case 'PING':
        _sendPong();
        break;
      case 'PONG':
        // Connection verified
        break;
      case '+OK':
        // Command acknowledged
        break;
      case '-ERR':
        print('NATS Error: ${parts.skip(1).join(' ')}');
        break;
    }
  }

  void _handleMessage(String msgLine) {
    // MSG format: MSG <subject> <sid> [reply-to] <#bytes>
    final parts = msgLine.split(' ');
    if (parts.length < 4) return;

    final subject = parts[1];
    final replyTo = parts.length > 4 ? parts[3] : null;
    final bytesStr = parts.last;
    final bytes = int.tryParse(bytesStr) ?? 0;

    if (bytes == 0) return;

    // Read the message payload
    Timer.run(() => _readMessagePayload(subject, replyTo, bytes));
  }

  void _readMessagePayload(String subject, String? replyTo, int bytes) {
    // For simplicity, assume the payload is in the buffer
    // In a real implementation, you'd need to handle partial reads
    if (_buffer.length >= bytes + 2) {
      final payload = _buffer.substring(0, bytes);
      _buffer = _buffer.substring(bytes + 2); // +2 for \r\n

      try {
        final envelope = Envelope.fromJson(jsonDecode(payload));
        
        if (replyTo != null) {
          // This is a request - handle it
          _handleRequest(envelope, replyTo);
        } else {
          // This is a response - complete the pending request
          _handleResponse(envelope);
        }
      } catch (e) {
        print('Failed to parse message payload: $e');
      }
    }
  }

  void _handleRequest(Envelope envelope, String replyTo) async {
    final handler = _handlers[envelope.subject];
    if (handler == null) {
      // Send "no responders" error
      return;
    }

    try {
      final result = await handler(envelope);
      final response = Envelope.newResponse(
        requestId: envelope.id,
        service: envelope.service,
        verb: envelope.verb,
        schema: envelope.schema,
        payload: result,
      );
      await _publish(replyTo, jsonEncode(response.toJson()));
    } catch (e) {
      final errorDetails = e is BusError 
          ? ErrorDetails(code: e.runtimeType.toString(), message: e.message)
          : ErrorDetails.internal('Handler error: $e');
      
      final errorResponse = Envelope.newError(
        requestId: envelope.id,
        service: envelope.service,
        verb: envelope.verb,
        schema: envelope.schema,
        error: errorDetails,
      );
      await _publish(replyTo, jsonEncode(errorResponse.toJson()));
    }
  }

  void _handleResponse(Envelope envelope) {
    final completer = _pendingRequests.remove(envelope.id);
    if (completer != null) {
      if (envelope.isError) {
        final error = envelope.error!;
        BusError busError;
        switch (error.code) {
          case 'BadRequest':
            busError = BusError.badRequest(error.message);
            break;
          case 'NotFound':
            busError = BusError.notFound(error.message);
            break;
          case 'Timeout':
            busError = BusError.timeout(error.message);
            break;
          default:
            busError = BusError.internal(error.message);
        }
        completer.completeError(busError);
      } else {
        completer.complete(envelope.payload ?? {});
      }
    }
  }

  Future<void> _sendConnect() async {
    final connectMsg = 'CONNECT {"verbose":false,"pedantic":false,"tls_required":false,"name":"","lang":"dart","version":"1.0.0","protocol":1}\r\n';
    _socket?.add(utf8.encode(connectMsg));
  }

  Future<void> _sendPing() async {
    _socket?.add(utf8.encode('PING\r\n'));
  }

  Future<void> _sendPong() async {
    _socket?.add(utf8.encode('PONG\r\n'));
  }

  @override
  Future<Map<String, dynamic>> request(Envelope envelope) async {
    if (!_isConnected) {
      throw ConnectionError('Not connected to NATS');
    }

    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[envelope.id] = completer;

    // Set up timeout
    Timer(config.requestTimeout, () {
      final pendingCompleter = _pendingRequests.remove(envelope.id);
      if (pendingCompleter != null && !pendingCompleter.isCompleted) {
        pendingCompleter.completeError(BusError.timeout());
      }
    });

    try {
      await _requestWithReply(envelope.subject, jsonEncode(envelope.toJson()));
      return await completer.future;
    } catch (e) {
      _pendingRequests.remove(envelope.id);
      rethrow;
    }
  }

  Future<void> _requestWithReply(String subject, String payload) async {
    final inbox = '_INBOX.${DateTime.now().millisecondsSinceEpoch}';
    
    // Subscribe to inbox for reply
    await _subscribe(inbox);
    
    // Publish request with reply-to
    final msg = 'PUB $subject $inbox ${payload.length}\r\n$payload\r\n';
    _socket?.add(utf8.encode(msg));
  }

  @override
  Future<void> subscribe(String subject, MessageHandler handler) async {
    if (!_isConnected) {
      throw ConnectionError('Not connected to NATS');
    }

    _handlers[subject] = handler;
    await _subscribe(subject);
  }

  Future<void> _subscribe(String subject) async {
    if (_subscriptions.containsKey(subject)) {
      return; // Already subscribed
    }

    final sid = _nextSid++;
    _subscriptions[subject] = sid;
    
    final subMsg = 'SUB $subject $sid\r\n';
    _socket?.add(utf8.encode(subMsg));
  }

  Future<void> _publish(String subject, String payload) async {
    final msg = 'PUB $subject ${payload.length}\r\n$payload\r\n';
    _socket?.add(utf8.encode(msg));
  }

  @override
  Future<void> close() async {
    _isConnected = false;
    await _subscription?.cancel();
    await _socket?.close();
    
    // Complete any pending requests with connection error
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(ConnectionError('Connection closed'));
      }
    }
    _pendingRequests.clear();
    _handlers.clear();
    _subscriptions.clear();
  }
}
