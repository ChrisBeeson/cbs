import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
// Note: Logger utility should be imported from the main app
// For now using print statements with proper formatting

/// Represents different types of bus messages for color coding
enum BusMessageType {
  ui,
  logic,
  error,
  other,
}

/// Data structure for captured bus messages
class BusMessage {
  final DateTime timestamp;
  final Envelope envelope;

  const BusMessage({
    required this.timestamp,
    required this.envelope,
  });

  /// Determine message type based on service name or error status
  BusMessageType get messageType {
    if (envelope.isError) {
      return BusMessageType.error;
    }
    
    final service = envelope.service.toLowerCase();
    if (service.contains('ui') || service.contains('flow')) {
      return BusMessageType.ui;
    } else if (service.contains('logic') || service.contains('process')) {
      return BusMessageType.logic;
    }
    
    return BusMessageType.other;
  }

  /// Get display color for this message type
  Color get displayColor {
    switch (messageType) {
      case BusMessageType.ui:
        return Colors.blue;
      case BusMessageType.logic:
        return Colors.green;
      case BusMessageType.error:
        return Colors.red;
      case BusMessageType.other:
        return Colors.white70;
    }
  }

  /// Format timestamp for display
  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}'
           '.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}

/// CBS Bus Monitor Cell for capturing and displaying all bus messages
class BusMonitorCell implements Cell {
  final ValueNotifier<List<BusMessage>> _messages = ValueNotifier([]);
  final ScrollController _scrollController = ScrollController();
  bool _disposed = false;

  @override
  String get id => 'bus_monitor';

  @override
  List<String> get subjects => ['cbs.>'];

  /// Reactive list of captured messages
  ValueNotifier<List<BusMessage>> get messages => _messages;

  /// Current message count
  int get messageCount => _messages.value.length;

  /// Scroll controller for auto-scroll functionality
  ScrollController get scrollController => _scrollController;

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    await bus.subscribe('cbs.>', _handleAllMessages);
  }

  /// Handle incoming bus messages
  Future<Map<String, dynamic>> _handleAllMessages(Envelope envelope) async {
    return await handleMessage(envelope);
  }

  /// Public method for handling messages (for testing)
  Future<Map<String, dynamic>> handleMessage(Envelope envelope) async {
    if (_disposed) {
      return {
        'status': 'error',
        'message': 'Cell is disposed',
      };
    }

    try {
      final message = BusMessage(
        timestamp: DateTime.now(),
        envelope: envelope,
      );

      // Add message to list
      final currentMessages = List<BusMessage>.from(_messages.value);
      currentMessages.add(message);
      _messages.value = currentMessages;

      // Auto-scroll to bottom with smooth animation
      _autoScrollToBottom();

      // Log message capture
      _logMessage(message);

      return {
        'status': 'captured',
        'message_id': envelope.id,
        'timestamp': message.timestamp.toIso8601String(),
      };
    } catch (e) {
      _logError('Failed to handle message: $e');
      return {
        'status': 'error',
        'message': 'Failed to capture message: $e',
      };
    }
  }

  /// Clear all captured messages
  void clearMessages() {
    if (_disposed) return;
    
    _messages.value = [];
    _logInfo('Messages cleared');
  }

  /// Auto-scroll to bottom of message list
  void _autoScrollToBottom() {
    if (_disposed || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Log message capture for debugging
  void _logMessage(BusMessage message) {
    print('\x1B[34m[DEBUG] ${DateTime.now().toIso8601String()} [BusMonitorCell] '
          'Bus message captured: ${message.envelope.service}.${message.envelope.verb} '
          'at ${message.formattedTimestamp}\x1B[0m');
  }

  /// Log info messages
  void _logInfo(String message) {
    print('\x1B[32m[INFO] ${DateTime.now().toIso8601String()} [BusMonitorCell] $message\x1B[0m');
  }

  /// Log error messages
  void _logError(String message) {
    print('\x1B[31m[ERROR] ${DateTime.now().toIso8601String()} [BusMonitorCell] $message\x1B[0m');
  }

  /// Dispose resources
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    _messages.dispose();
    _scrollController.dispose();
    _logInfo('Cell disposed');
  }
}
