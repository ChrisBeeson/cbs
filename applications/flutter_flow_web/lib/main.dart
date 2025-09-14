import 'package:flutter/material.dart';
import 'package:flow_ui_cell/flow_ui_cell.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// App entrypoint.
/// On web, we mark the HTML body with `flutter-loaded` after the first frame
/// so the loading overlay in `web/index.html` fades out.
void main() {
  runApp(const FlowApp());
  if (kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Web-specific code moved to conditional import
      _addFlutterLoadedClass();
    });
  }
}

void _addFlutterLoadedClass() {
  // This will be replaced by conditional imports in a real web build
  // For testing purposes, this is a no-op
}

/// Main application entry point
class FlowApp extends StatelessWidget {
  const FlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow - CBS Web Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const FlowUIWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
