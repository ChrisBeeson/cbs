/// Simple logger utility for CBS applications
class Logger {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';

  /// Debug logging (blue)
  static void d(String message, [String? tag]) {
    _log('DEBUG', message, _blue, tag);
  }

  /// Info logging (green)
  static void i(String message, [String? tag]) {
    _log('INFO', message, _green, tag);
  }

  /// Warning logging (yellow)
  static void w(String message, [String? tag]) {
    _log('WARN', message, _yellow, tag);
  }

  /// Error logging (red)
  static void e(String message, [String? tag]) {
    _log('ERROR', message, _red, tag);
  }

  static void _log(String level, String message, String color, String? tag) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag] ' : '';
    print('$color[$level] $timestamp $tagStr$message$_reset');
  }
}

// Global logger instance for convenience
final log = Logger;
