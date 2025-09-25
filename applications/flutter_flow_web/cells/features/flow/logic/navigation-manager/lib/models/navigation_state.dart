/// Navigation state data model
class NavigationState {
  final String currentScreen;
  final List<String> history;
  final Map<String, dynamic> currentParams;
  final DateTime lastChanged;

  const NavigationState({
    required this.currentScreen,
    this.history = const [],
    this.currentParams = const {},
    required this.lastChanged,
  });

  NavigationState copyWith({
    String? currentScreen,
    List<String>? history,
    Map<String, dynamic>? currentParams,
    DateTime? lastChanged,
  }) {
    return NavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      history: history ?? this.history,
      currentParams: currentParams ?? this.currentParams,
      lastChanged: lastChanged ?? this.lastChanged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_screen': currentScreen,
      'history': history,
      'current_params': currentParams,
      'last_changed': lastChanged.toIso8601String(),
    };
  }

  static NavigationState fromJson(Map<String, dynamic> json) {
    return NavigationState(
      currentScreen: json['current_screen'] ?? '',
      history: List<String>.from(json['history'] ?? []),
      currentParams: Map<String, dynamic>.from(json['current_params'] ?? {}),
      lastChanged: DateTime.parse(json['last_changed'] ?? DateTime.now().toIso8601String()),
    );
  }
}
