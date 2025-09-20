import 'package:flutter/material.dart';

/// Modular Flow Text Widget with customizable styling and visibility
class FlowTextWidget extends StatelessWidget {
  final bool visible;
  final double? fontSize;
  final Color? color;
  final Color? glowColor;
  final double letterSpacing;
  final List<Shadow>? customShadows;

  const FlowTextWidget({
    Key? key,
    this.visible = true,
    this.fontSize,
    this.color,
    this.glowColor,
    this.letterSpacing = 4.0,
    this.customShadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final effectiveColor = color ?? const Color(0xFF00D4FF);
    final effectiveGlowColor = glowColor ?? effectiveColor.withValues(alpha: 0.5);
    final effectiveFontSize = fontSize ?? _getResponsiveFontSize(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Flow',
          semanticsLabel: 'Flow - Main Application Title',
          style: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.bold,
            color: effectiveColor,
            letterSpacing: letterSpacing,
            shadows: customShadows ?? [
              Shadow(
                blurRadius: 20.0,
                color: effectiveGlowColor,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                effectiveColor,
                effectiveColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Get responsive font size based on screen width
  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return 48.0; // Mobile
    } else if (screenWidth < 1200) {
      return 72.0; // Tablet
    } else {
      return 96.0; // Desktop
    }
  }
}

/// Flow Text Cell for state management and visibility control
class FlowTextCell {
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier(true);
  bool _disposed = false;

  /// Get visibility notifier for reactive updates
  ValueNotifier<bool> get visibilityNotifier => _visibilityNotifier;

  /// Get current visibility state
  bool get isVisible => _disposed ? false : _visibilityNotifier.value;

  /// Toggle current visibility state
  void toggleVisibility() {
    if (_disposed) return;
    
    _visibilityNotifier.value = !_visibilityNotifier.value;
    _logVisibilityChange();
  }

  /// Set explicit visibility state
  void setVisibility(bool visible) {
    if (_disposed || _visibilityNotifier.value == visible) return;
    
    _visibilityNotifier.value = visible;
    _logVisibilityChange();
  }

  /// Log visibility changes
  void _logVisibilityChange() {
    final state = _visibilityNotifier.value ? 'visible' : 'hidden';
    print('\x1B[34m[DEBUG] ${DateTime.now().toIso8601String()} [FlowTextCell] '
          'Visibility changed to: $state\x1B[0m');
  }

  /// Dispose resources
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    _visibilityNotifier.dispose();
    print('\x1B[32m[INFO] ${DateTime.now().toIso8601String()} [FlowTextCell] '
          'Cell disposed\x1B[0m');
  }
}
