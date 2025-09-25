import 'package:cbs_sdk/cbs_sdk.dart';

// Export the navbar widget for use by other parts of the app
export 'widgets/navbar_widget.dart';

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

/// Navbar UI Cell - handles navigation bar user interface
class NavbarUICell implements Cell {
  BodyBus? _bus;
  bool _disposed = false;
  String _currentScreen = 'screen_home';

  @override
  String get id => 'navbar_ui';

  @override
  List<String> get subjects => [
    'cbs.navigation.current_response',
    'cbs.navigation.screen_changed',
  ];

  /// Get current screen
  String get currentScreen => _currentScreen;

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    
    _bus = bus;
    await bus.subscribe('cbs.navigation.current_response', handleCurrentResponse);
    await bus.subscribe('cbs.navigation.screen_changed', handleScreenChanged);
    
    _LogShim.i('[NavbarUICell] registered with bus');
    
    // Request current navigation state
    await _requestCurrentScreen();
  }

  /// Handle current screen response
  Future<Map<String, dynamic>> handleCurrentResponse(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final currentScreen = payload['current_screen'] as String?;

      if (currentScreen != null) {
        _currentScreen = currentScreen;
        _LogShim.d('[NavbarUICell] updated current screen: $currentScreen');
      }

      return {
        'status': 'handled',
        'current_screen': currentScreen,
      };
    } catch (e) {
      _LogShim.e('[NavbarUICell] current_response error: $e');
      return _errorResponse('Failed to handle current response: $e');
    }
  }

  /// Handle screen change notification
  Future<Map<String, dynamic>> handleScreenChanged(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final currentScreen = payload['current_screen'] as String?;

      if (currentScreen != null) {
        _currentScreen = currentScreen;
        _LogShim.i('[NavbarUICell] screen changed to: $currentScreen');
      }

      return {
        'status': 'handled',
        'current_screen': currentScreen,
      };
    } catch (e) {
      _LogShim.e('[NavbarUICell] screen_changed error: $e');
      return _errorResponse('Failed to handle screen change: $e');
    }
  }

  /// Request screen change via navigation manager
  Future<void> requestScreenChange(String screenId, {Map<String, dynamic>? params}) async {
    if (_disposed || _bus == null) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'navigation',
        verb: 'set_screen',
        schema: 'navigation.set_screen.v1',
        payload: {
          'screen_id': screenId,
          if (params != null) 'params': params,
        },
      );

      await _bus!.request(envelope);
      _LogShim.i('[NavbarUICell] requesting screen change to: $screenId');
    } catch (e) {
      _LogShim.e('[NavbarUICell] failed to request screen change: $e');
    }
  }

  /// Request current screen state
  Future<void> _requestCurrentScreen() async {
    if (_disposed || _bus == null) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'navigation',
        verb: 'get_current',
        schema: 'navigation.get_current.v1',
        payload: {},
      );

      await _bus!.request(envelope);
      _LogShim.d('[NavbarUICell] requested current screen state');
    } catch (e) {
      _LogShim.e('[NavbarUICell] failed to request current screen: $e');
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
    _LogShim.i('[NavbarUICell] disposed');
  }
}