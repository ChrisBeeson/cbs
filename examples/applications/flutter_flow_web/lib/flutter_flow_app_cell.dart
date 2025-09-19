import 'package:cbs_sdk/cbs_sdk.dart';

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

/// Main application cell that coordinates all other cells via bus messages only
class FlutterFlowAppCell implements Cell {
  final BodyBus _bus;
  bool _disposed = false;

  FlutterFlowAppCell(this._bus);

  @override
  String get id => 'flutter_flow_app';

  @override
  List<String> get subjects => [
    'cbs.app.start',
    'cbs.app.stop',
  ];

  // Direct cell access removed - use bus communication only

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;

    _LogShim.i('[FlutterFlowAppCell] Registering app coordinator...');
    
    try {
      // Subscribe to app lifecycle events
      await bus.subscribe('cbs.app.start', handleAppStart);
      await bus.subscribe('cbs.app.stop', handleAppStop);
      
      _LogShim.i('[FlutterFlowAppCell] App coordinator registered successfully');
      
      // Start the application
      await _startApplication();
      
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to register app coordinator: $e');
      rethrow;
    }
  }

  /// Handle application start
  Future<Map<String, dynamic>> handleAppStart(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      _LogShim.i('[FlutterFlowAppCell] Application start requested');
      await _startApplication();
      
      return {
        'status': 'success',
        'message': 'Application started',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to start application: $e');
      return _errorResponse('Failed to start application: $e');
    }
  }

  /// Handle application stop
  Future<Map<String, dynamic>> handleAppStop(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      _LogShim.i('[FlutterFlowAppCell] Application stop requested');
      await _stopApplication();
      
      return {
        'status': 'success',
        'message': 'Application stopped',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to stop application: $e');
      return _errorResponse('Failed to stop application: $e');
    }
  }

  /// Start the application
  Future<void> _startApplication() async {
    if (_disposed) return;

    try {
      _LogShim.i('[FlutterFlowAppCell] Starting application...');
      
      // Initialize default flow text content
      await _initializeFlowText();
      
      // Set initial navigation state
      await _initializeNavigation();
      
      _LogShim.i('[FlutterFlowAppCell] Application started successfully');
      
      // Publish app ready event  
      await _publishAppReady();
      
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to start application: $e');
      rethrow;
    }
  }

  /// Stop the application
  Future<void> _stopApplication() async {
    if (_disposed) return;

    try {
      _LogShim.i('[FlutterFlowAppCell] Stopping application...');
      
      // Publish app shutdown event
      await _publishAppShutdown();
      
      _LogShim.i('[FlutterFlowAppCell] Application stopped successfully');
      
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to stop application: $e');
    }
  }

  /// Initialize flow text content
  Future<void> _initializeFlowText() async {
    try {
      // Set initial flow text visibility via bus
      final envelope = Envelope.newRequest(
        service: 'flow_text',
        verb: 'set_visibility',
        schema: 'flow_text.set_visibility.v1',
        payload: {'visible': true},
      );
      
      await _bus.request(envelope);
      _LogShim.d('[FlutterFlowAppCell] Flow text initialized via bus');
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to initialize flow text: $e');
    }
  }

  /// Initialize navigation to home screen
  Future<void> _initializeNavigation() async {
    try {
      final envelope = Envelope.newRequest(
        service: 'navigation',
        verb: 'set_screen',
        schema: 'navigation.set_screen.v1',
        payload: {'screen_id': 'screen_home'},
      );
      
      await _bus.request(envelope);
      _LogShim.d('[FlutterFlowAppCell] Navigation initialized to home screen');
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to initialize navigation: $e');
    }
  }

  /// Publish app ready event
  Future<void> _publishAppReady() async {
    try {
      final envelope = Envelope.newRequest(
        service: 'app',
        verb: 'ready',
        schema: 'app.ready.v1',
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'coordinator_ready': true,
        },
      );
      
      await _bus.request(envelope);
      _LogShim.d('[FlutterFlowAppCell] Published app ready event');
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to publish app ready: $e');
    }
  }

  /// Publish app shutdown event
  Future<void> _publishAppShutdown() async {
    try {
      final envelope = Envelope.newRequest(
        service: 'app',
        verb: 'shutdown',
        schema: 'app.shutdown.v1',
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      await _bus.request(envelope);
      _LogShim.d('[FlutterFlowAppCell] Published app shutdown event');
    } catch (e) {
      _LogShim.e('[FlutterFlowAppCell] Failed to publish app shutdown: $e');
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
    
    // App coordinator disposal - individual cells manage their own lifecycle
    _LogShim.i('[FlutterFlowAppCell] disposed');
  }
}
