/// Screen metadata model
class ScreenInfo {
  final String id;
  final String name;
  final String? description;
  final bool enabled;
  final Map<String, dynamic> defaultParams;

  const ScreenInfo({
    required this.id,
    required this.name,
    this.description,
    this.enabled = true,
    this.defaultParams = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'enabled': enabled,
      'default_params': defaultParams,
    };
  }

  static ScreenInfo fromJson(Map<String, dynamic> json) {
    return ScreenInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      enabled: json['enabled'] ?? true,
      defaultParams: Map<String, dynamic>.from(json['default_params'] ?? {}),
    );
  }
}
