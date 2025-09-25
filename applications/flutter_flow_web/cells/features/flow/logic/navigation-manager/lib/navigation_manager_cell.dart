import 'package:cbs_sdk/cbs_sdk.dart';
import 'services/navigation_service.dart';

/// Log shim for cell-level logging
class _LogShim {
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
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

  static void w(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_yellow[WARN] $ts $message$_reset');
  }

  static void e(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_red[ERROR] $ts $message$_reset');
  }
}

/// Navigation Manager Cell - handles application navigation logic
class NavigationManagerCell implements Cell {
  final NavigationService _navigationService = NavigationService();
  BodyBus? _bus;
  bool _disposed = false;

  @override
  String get id => 'navigation_manager';

  @override
  List<String> get subjects => [
    'cbs.navigation.get_current',
    'cbs.navigation.set_screen',
    'cbs.navigation.get_screens',
  ];

  /// Get navigation service (for testing)
  NavigationService get navigationService => _navigationService;

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    
    _bus = bus;
    await bus.subscribe('cbs.navigation.get_current', handleGetCurrent);
    await bus.subscribe('cbs.navigation.set_screen', handleSetScreen);
    await bus.subscribe('cbs.navigation.get_screens', handleGetScreens);
    
    _LogShim.i('[NavigationManagerCell] registered with bus');
  }

  /// Handle get current screen request
  Future<Map<String, dynamic>> handleGetCurrent(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final state = _navigationService.currentState;
      
      _LogShim.d('[NavigationManagerCell] get_current: ${state.currentScreen}');
      
      return {
        'status': 'success',
        'current_screen': state.currentScreen,
        'params': state.currentParams,
        'history': state.history,
        'last_changed': state.lastChanged.toIso8601String(),
      };
    } catch (e) {
      _LogShim.e('[NavigationManagerCell] get_current error: $e');
      return _errorResponse('Failed to get current screen: $e');
    }
  }

  /// Handle set screen request
  Future<Map<String, dynamic>> handleSetScreen(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final payload = envelope.payload ?? <String, dynamic>{};
      final screenId = payload['screen_id'] as String?;
      final params = payload['params'] as Map<String, dynamic>?;

      if (screenId == null || screenId.isEmpty) {
        return _errorResponse('screen_id is required');
      }

      final result = _navigationService.setScreen(screenId, params: params);
      
      if (result.success) {
        _LogShim.i('[NavigationManagerCell] screen changed: ${result.previousScreen} -> ${result.currentScreen}');
        
        // Notify screen change via bus
        await _notifyScreenChanged(result);
        
        return {
          'status': 'success',
          'previous_screen': result.previousScreen,
          'current_screen': result.currentScreen,
          'timestamp': result.timestamp.toIso8601String(),
        };
      } else {
        _LogShim.w('[NavigationManagerCell] set_screen failed: ${result.error}');
        return _errorResponse(result.error ?? 'Unknown navigation error');
      }
    } catch (e) {
      _LogShim.e('[NavigationManagerCell] set_screen error: $e');
      return _errorResponse('Failed to set screen: $e');
    }
  }

  /// Handle get screens request
  Future<Map<String, dynamic>> handleGetScreens(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      final screens = _navigationService.availableScreens;
      
      _LogShim.d('[NavigationManagerCell] get_screens: ${screens.length} available');
      
      return {
        'status': 'success',
        'screens': screens.map((id, info) => MapEntry(id, info.toJson())),
        'count': screens.length,
      };
    } catch (e) {
      _LogShim.e('[NavigationManagerCell] get_screens error: $e');
      return _errorResponse('Failed to get screens: $e');
    }
  }

  /// Notify other cells about screen changes
  Future<void> _notifyScreenChanged(NavigationResult result) async {
    if (_bus == null || _disposed) return;

    try {
      final envelope = Envelope.newRequest(
        service: 'navigation',
        verb: 'screen_changed',
        schema: 'navigation.screen_changed.v1',
        payload: {
          'previous_screen': result.previousScreen,
          'current_screen': result.currentScreen,
          'timestamp': result.timestamp.toIso8601String(),
        },
      );

      await _bus!.request(envelope);
      _LogShim.d('[NavigationManagerCell] published screen_changed event');
    } catch (e) {
      _LogShim.e('[NavigationManagerCell] failed to notify screen change: $e');
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
    _LogShim.i('[NavigationManagerCell] disposed');
  }
}