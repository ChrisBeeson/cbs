import 'package:cbs_sdk/cbs_sdk.dart';

// Export the monitor screen widget for use by other parts of the app
export 'widgets/monitor_screen_widget.dart';

/// Log shim for cell-level logging
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

  static void e(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_red[ERROR] $ts $message$_reset');
  }
}

/// Screen Monitor Cell - handles bus monitor screen UI component
class ScreenMonitorCell implements Cell {
  BodyBus? _bus;
  bool _disposed = false;
  bool _isActive = false;
  List<Map<String, dynamic>> _messages = [];

  @override
  String get id => 'screen_monitor';

  @override
  List<String> get subjects => [
    'cbs.navigation.screen_changed',
    'cbs.bus_monitor.messages_updated',
  ];

  /// Get screen active state
  bool get isActive => _isActive;

  /// Get messages
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    
    _bus = bus;
    await bus.subscribe('cbs.navigation.screen_changed', handleScreenChanged);
    await bus.subscribe('cbs.bus_monitor.messages_updated', handleMessagesUpdated);
    
    _LogShim.i('[ScreenMonitorCell] registered with bus');
  }

  /// Handle navigation screen change
  Future<Map<String, dynamic>> handleScreenChanged(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final currentScreen = payload['current_screen'] as String?;

      if (currentScreen == 'screen_monitor') {
        _isActive = true;
        _LogShim.i('[ScreenMonitorCell] screen activated');
        
        // Request bus messages
        await _requestBusMessages();
      } else {
        _isActive = false;
        _LogShim.d('[ScreenMonitorCell] screen deactivated');
      }

      return {
        'status': 'handled',
        'screen_active': currentScreen == 'screen_monitor',
      };
    } catch (e) {
      _LogShim.e('[ScreenMonitorCell] screen_changed error: $e');
      return _errorResponse('Failed to handle screen change: $e');
    }
  }

  /// Handle bus monitor messages updated
  Future<Map<String, dynamic>> handleMessagesUpdated(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final messages = payload['messages'] as List<dynamic>? ?? [];

      // Convert messages to proper format
      _messages = messages.map((msg) {
        if (msg is Map<String, dynamic>) {
          return msg;
        }
        return <String, dynamic>{};
      }).toList();
      
      _LogShim.d('[ScreenMonitorCell] updated ${messages.length} messages');

      return {
        'status': 'handled',
        'message_count': messages.length,
      };
    } catch (e) {
      _LogShim.e('[ScreenMonitorCell] messages_updated error: $e');
      return _errorResponse('Failed to handle messages update: $e');
    }
  }

  /// Request bus messages from bus monitor
  Future<void> _requestBusMessages() async {
    if (_bus == null || _disposed) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'bus_monitor',
        verb: 'get_messages',
        schema: 'bus_monitor.get_messages.v1',
        payload: {
          'limit': 500,
        },
      );

      await _bus!.request(envelope);
      _LogShim.d('[ScreenMonitorCell] requested bus messages');
    } catch (e) {
      _LogShim.e('[ScreenMonitorCell] failed to request messages: $e');
    }
  }

  /// Request clear messages
  Future<void> requestClearMessages() async {
    if (_disposed || _bus == null) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'bus_monitor',
        verb: 'clear',
        schema: 'bus_monitor.clear.v1',
        payload: {},
      );

      await _bus!.request(envelope);
      _LogShim.i('[ScreenMonitorCell] clear messages requested');
    } catch (e) {
      _LogShim.e('[ScreenMonitorCell] failed to request clear: $e');
    }
  }

  /// Add single message (for real-time updates)
  void addMessage(Map<String, dynamic> message) {
    if (_disposed) return;

    try {
      _messages.add(message);
      
      // Limit messages to prevent memory issues
      if (_messages.length > 500) {
        _messages.removeAt(0);
      }
      
      _LogShim.d('[ScreenMonitorCell] added message: ${message['subject']}');
    } catch (e) {
      _LogShim.e('[ScreenMonitorCell] failed to add message: $e');
    }
  }

  /// Helper to create error response
  Map<String, dynamic> _errorResponse(String message) {
    return {
      'status': 'error',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    _bus = null;
    _LogShim.i('[ScreenMonitorCell] disposed');
  }
}