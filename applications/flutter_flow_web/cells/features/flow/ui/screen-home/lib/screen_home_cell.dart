import 'package:cbs_sdk/cbs_sdk.dart';

// Export the home screen widget for use by other parts of the app
export 'widgets/home_screen_widget.dart';

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

/// Screen Home Cell - handles home screen UI component
class ScreenHomeCell implements Cell {
  BodyBus? _bus;
  bool _disposed = false;
  bool _isActive = false;
  String? _flowContent;

  @override
  String get id => 'screen_home';

  @override
  List<String> get subjects => [
    'cbs.navigation.screen_changed',
    'cbs.flow_text.content_ready',
  ];

  /// Get screen active state
  bool get isActive => _isActive;

  /// Get flow content
  String? get flowContent => _flowContent;

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    
    _bus = bus;
    await bus.subscribe('cbs.navigation.screen_changed', handleScreenChanged);
    await bus.subscribe('cbs.flow_text.content_ready', handleContentReady);
    
    _LogShim.i('[ScreenHomeCell] registered with bus');
  }

  /// Handle navigation screen change
  Future<Map<String, dynamic>> handleScreenChanged(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final currentScreen = payload['current_screen'] as String?;

      if (currentScreen == 'screen_home') {
        _isActive = true;
        _LogShim.i('[ScreenHomeCell] screen activated');
        
        // Request flow text content
        await _requestFlowContent();
      } else {
        _isActive = false;
        _LogShim.d('[ScreenHomeCell] screen deactivated');
      }

      return {
        'status': 'handled',
        'screen_active': currentScreen == 'screen_home',
      };
    } catch (e) {
      _LogShim.e('[ScreenHomeCell] screen_changed error: $e');
      return _errorResponse('Failed to handle screen change: $e');
    }
  }

  /// Handle flow text content ready
  Future<Map<String, dynamic>> handleContentReady(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final content = payload['content'] as String?;

      if (content != null) {
        _flowContent = content;
        _LogShim.d('[ScreenHomeCell] flow content updated');
      }

      return {
        'status': 'handled',
        'content_length': content?.length ?? 0,
      };
    } catch (e) {
      _LogShim.e('[ScreenHomeCell] content_ready error: $e');
      return _errorResponse('Failed to handle content: $e');
    }
  }

  /// Request flow text content
  Future<void> _requestFlowContent() async {
    if (_bus == null || _disposed) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'flow_text',
        verb: 'get_content',
        schema: 'flow_text.get_content.v1',
        payload: {},
      );

      await _bus!.request(envelope);
      _LogShim.d('[ScreenHomeCell] requested flow content');
    } catch (e) {
      _LogShim.e('[ScreenHomeCell] failed to request content: $e');
    }
  }

  /// Request content update
  Future<void> requestContentUpdate(String content) async {
    if (_disposed || _bus == null) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'flow_text',
        verb: 'update_content',
        schema: 'flow_text.update_content.v1',
        payload: {'content': content},
      );

      await _bus!.request(envelope);
      _LogShim.i('[ScreenHomeCell] content update requested');
    } catch (e) {
      _LogShim.e('[ScreenHomeCell] failed to request content update: $e');
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
    _LogShim.i('[ScreenHomeCell] disposed');
  }
}