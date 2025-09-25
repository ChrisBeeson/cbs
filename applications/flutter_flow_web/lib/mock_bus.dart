import 'dart:async';
import 'package:cbs_sdk/cbs_sdk.dart';

/// Mock implementation of BodyBus for demo purposes
/// Simulates bus messaging without requiring NATS connection
class MockBodyBus implements BodyBus {
  final Map<String, MessageHandler> _handlers = {};
  bool _isConnected = true;
  
  @override
  bool get isConnected => _isConnected;

  @override
  Future<Map<String, dynamic>> request(Envelope envelope) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Find handler for this subject
    final handler = _handlers[envelope.subject];
    if (handler != null) {
      return await handler(envelope);
    }
    
    // No handler found - return success response
    return {
      'status': 'no_handler',
      'subject': envelope.subject,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> subscribe(String subject, MessageHandler handler) async {
    _handlers[subject] = handler;
    print('\x1B[36m[DEBUG] ${DateTime.now().toIso8601String()} [MockBus] '
          'Subscribed to: $subject\x1B[0m');
  }

  /// Simulate publishing a message to trigger handlers
  Future<void> simulateMessage(Envelope envelope) async {
    // Check for wildcard subscriptions (e.g., 'cbs.>')
    for (final subject in _handlers.keys) {
      if (_matchesSubject(subject, envelope.subject)) {
        final handler = _handlers[subject]!;
        try {
          await handler(envelope);
          print('\x1B[36m[DEBUG] ${DateTime.now().toIso8601String()} [MockBus] '
                'Message delivered to handler: $subject\x1B[0m');
        } catch (e) {
          print('\x1B[31m[ERROR] ${DateTime.now().toIso8601String()} [MockBus] '
                'Handler error for $subject: $e\x1B[0m');
        }
      }
    }
  }

  /// Check if a subscription subject matches a message subject
  bool _matchesSubject(String subscription, String messageSubject) {
    if (subscription == messageSubject) return true;
    
    // Handle wildcard subscriptions
    if (subscription.endsWith('>')) {
      final prefix = subscription.substring(0, subscription.length - 1);
      return messageSubject.startsWith(prefix);
    }
    
    return false;
  }

  @override
  Future<void> close() async {
    _isConnected = false;
    _handlers.clear();
    print('\x1B[32m[INFO] ${DateTime.now().toIso8601String()} [MockBus] '
          'Bus connection closed\x1B[0m');
  }
}
