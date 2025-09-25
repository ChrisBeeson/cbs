import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
// Note: In package context we cannot import the app-level logger to avoid tight coupling.
// Provide a minimal shim matching log.d/i/w/e interface.
class _LogShim {
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';

  static void d(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_blue[DEBUG] $ts $message$_reset');
  }

  static void i(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_green[INFO] $ts $message$_reset');
  }

  // Intentionally omit 'w' to avoid unused warning.

  static void e(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_red[ERROR] $ts $message$_reset');
  }
}

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

  /// NATS channel for this message
  String get channel => envelope.subject;

  /// Payload type parsed from schema (service/version/Type -> Type)
  String get payloadType => SchemaInfo.from(envelope.schema).payloadType;

  /// Human description from registry
  String get description => MessageDescriptionRegistry.get(
        envelope.service,
        envelope.verb,
      );

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

/// Parsed schema info helper
class SchemaInfo {
  final String service;
  final String version;
  final String payloadType;

  const SchemaInfo({
    required this.service,
    required this.version,
    required this.payloadType,
  });

  static SchemaInfo from(String schema) {
    final parts = schema.split('/');
    if (parts.length >= 3) {
      return SchemaInfo(
        service: parts[0],
        version: parts[1],
        payloadType: parts.last.isNotEmpty ? parts.last : 'Data',
      );
    }
    if (parts.length == 2) {
      return SchemaInfo(
        service: parts[0],
        version: parts[1],
        payloadType: 'Data',
      );
    }
    return const SchemaInfo(service: 'unknown', version: 'v1', payloadType: 'Data');
  }
}

/// Message description lookup
class MessageDescriptionRegistry {
  static final Map<String, String> _map = <String, String>{
    'greeter.say_hello': 'Process user name for greeting',
    'flow_ui.toggle': 'Toggle Flow UI visibility',
    'bus_monitor.clear': 'Clear monitor messages',
  };

  static String get(String service, String verb) {
    return _map['$service.$verb'] ?? '';
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
  List<String> get subjects => ['cbs.>', 'cbs.bus_monitor.clear'];

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
    await bus.subscribe('cbs.bus_monitor.clear', _handleClearCommand);
  }

  /// Handle incoming bus messages
  Future<Map<String, dynamic>> _handleAllMessages(Envelope envelope) async {
    return await handleMessage(envelope);
  }

  /// Handle clear command subject
  Future<Map<String, dynamic>> _handleClearCommand(Envelope envelope) async {
    clearMessages();
    return {
      'status': 'cleared',
      'message': 'Bus monitor buffer cleared',
    };
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
      // Enforce 500-cap, drop oldest
      if (currentMessages.length > 500) {
        currentMessages.removeAt(0);
      }
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
    _LogShim.d('[BusMonitorCell] captured ${message.envelope.service}.${message.envelope.verb} at ${message.formattedTimestamp}');
  }

  /// Log info messages
  void _logInfo(String message) {
    _LogShim.i('[BusMonitorCell] $message');
  }

  /// Log error messages
  void _logError(String message) {
    _LogShim.e('[BusMonitorCell] $message');
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
