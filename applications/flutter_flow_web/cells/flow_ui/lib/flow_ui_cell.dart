import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';

/// Flow UI Cell - renders "Flow" centered with modern styling
class FlowUICell implements Cell {
  @override
  String get id => 'flow_ui';

  @override
  List<String> get subjects => ['cbs.flow_ui.render'];

  @override
  Future<void> register(BodyBus bus) async {
    await bus.subscribe('cbs.flow_ui.render', _handleRender);
  }

  /// Handle render requests
  Future<Map<String, dynamic>> _handleRender(Envelope envelope) async {
    return handleRender(envelope);
  }

  /// Public method for handling render requests (for testing)
  Future<Map<String, dynamic>> handleRender(dynamic envelope) async {
    // In a real implementation, this would trigger UI updates
    // For now, return success status
    return {
      'status': 'rendered',
      'component': 'flow',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Flutter widget that renders "Flow" with modern styling
class FlowUIWidget extends StatelessWidget {
  const FlowUIWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Flow',
              semanticsLabel: 'Flow - Main Application Title',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00D4FF), // Bright cyan
                letterSpacing: 4.0,
                shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: const Color(0xFF00D4FF).withOpacity(0.5),
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF0099CC),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
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

/// Main app widget for Flutter web
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
      ),
      home: const FlowUIWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
