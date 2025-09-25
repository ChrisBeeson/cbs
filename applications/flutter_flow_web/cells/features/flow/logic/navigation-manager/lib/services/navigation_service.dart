import '../models/navigation_state.dart';
import '../models/screen_info.dart';

/// Core navigation logic service
class NavigationService {
  static final Map<String, ScreenInfo> _availableScreens = {
    'screen_home': const ScreenInfo(
      id: 'screen_home',
      name: 'Home',
      description: 'Main application home screen',
    ),
    'screen_monitor': const ScreenInfo(
      id: 'screen_monitor', 
      name: 'Bus Monitor',
      description: 'Real-time bus message monitoring',
    ),
    'screen_settings': const ScreenInfo(
      id: 'screen_settings',
      name: 'Settings',
      description: 'Application settings and configuration',
      enabled: false, // Future implementation
    ),
  };

  NavigationState _currentState = NavigationState(
    currentScreen: 'screen_home',
    lastChanged: DateTime.now(),
  );

  /// Get current navigation state
  NavigationState get currentState => _currentState;

  /// Get all available screens
  Map<String, ScreenInfo> get availableScreens => Map.unmodifiable(_availableScreens);

  /// Validate if screen transition is allowed
  bool isValidScreen(String screenId) {
    final screen = _availableScreens[screenId];
    return screen != null && screen.enabled;
  }

  /// Set active screen with validation
  NavigationResult setScreen(String screenId, {Map<String, dynamic>? params}) {
    if (!isValidScreen(screenId)) {
      return NavigationResult.error('Invalid screen: $screenId');
    }

    final previousScreen = _currentState.currentScreen;
    final history = List<String>.from(_currentState.history);
    
    // Add previous screen to history if different
    if (previousScreen != screenId) {
      history.add(previousScreen);
      // Limit history size
      if (history.length > 10) {
        history.removeAt(0);
      }
    }

    _currentState = _currentState.copyWith(
      currentScreen: screenId,
      history: history,
      currentParams: params ?? {},
      lastChanged: DateTime.now(),
    );

    return NavigationResult.success(
      previousScreen: previousScreen,
      currentScreen: screenId,
    );
  }

  /// Get screen info by ID
  ScreenInfo? getScreenInfo(String screenId) {
    return _availableScreens[screenId];
  }

  /// Get navigation history
  List<String> getHistory() {
    return List.unmodifiable(_currentState.history);
  }
}

/// Navigation operation result
class NavigationResult {
  final bool success;
  final String? error;
  final String? previousScreen;
  final String? currentScreen;
  final DateTime timestamp;

  NavigationResult._({
    required this.success,
    this.error,
    this.previousScreen,
    this.currentScreen,
  }) : timestamp = DateTime.now();

  factory NavigationResult.success({
    String? previousScreen,
    String? currentScreen,
  }) {
    return NavigationResult._(
      success: true,
      previousScreen: previousScreen,
      currentScreen: currentScreen,
    );
  }

  factory NavigationResult.error(String error) {
    return NavigationResult._(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'previous_screen': previousScreen,
      'current_screen': currentScreen,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
