import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flow_ui_cell/flow_ui_cell.dart';
import 'mock_bus.dart';
import 'dart:html' as html show document;

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
  // Add flutter-loaded class to body to hide loading spinner
  html.document.body?.classes.add('flutter-loaded');
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
      home: FlowUIWidget(bus: MockBodyBus()),
      debugShowCheckedModeBanner: false,
    );
  }
}
