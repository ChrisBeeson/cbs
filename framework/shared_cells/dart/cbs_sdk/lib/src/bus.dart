import 'envelope.dart';

/// Message handler function type for processing CBS envelopes
typedef MessageHandler = Future<Map<String, dynamic>> Function(Envelope envelope);

/// Message bus interface for request/reply and subscription patterns
abstract class BodyBus {
  /// Send a request and wait for a reply
  Future<Map<String, dynamic>> request(Envelope envelope);

  /// Subscribe to a subject with a handler function
  Future<void> subscribe(String subject, MessageHandler handler);

  /// Check if the bus is connected
  bool get isConnected;

  /// Close the connection and clean up resources
  Future<void> close();
}
