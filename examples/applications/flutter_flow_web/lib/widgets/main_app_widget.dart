import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import 'package:navbar_ui_cell/navbar_ui_cell.dart';
import 'package:screen_home_cell/screen_home_cell.dart';
import 'package:screen_monitor_cell/screen_monitor_cell.dart';
import '../flutter_flow_app_cell.dart';

/// Main application widget with navbar and screen routing
class MainAppWidget extends StatefulWidget {
  final BodyBus bus;

  const MainAppWidget({Key? key, required this.bus}) : super(key: key);

  @override
  State<MainAppWidget> createState() => _MainAppWidgetState();
}

class _MainAppWidgetState extends State<MainAppWidget> {
  late FlutterFlowAppCell _appCell;
  late NavbarUICell _navbarCell;
  String _currentScreen = 'screen_home';

  @override
  void initState() {
    super.initState();
    _initializeCells();
  }

  Future<void> _initializeCells() async {
    // Initialize app coordinator cell
    _appCell = FlutterFlowAppCell(widget.bus);
    await _appCell.register(widget.bus);

    // Initialize navbar cell
    _navbarCell = NavbarUICell();
    await _navbarCell.register(widget.bus);

    // Subscribe to navigation changes
    await widget.bus.subscribe('cbs.navigation.screen_changed', (envelope) async {
      if (mounted) {
        final currentScreen = envelope.payload?['current_screen'] as String?;
        if (currentScreen != null && currentScreen != _currentScreen) {
          setState(() {
            _currentScreen = currentScreen;
          });
        }
      }
      return {'status': 'handled'};
    });

    print('\x1B[32m[INFO] ${DateTime.now().toIso8601String()} [MainAppWidget] '
          'Cells initialized\x1B[0m');
  }

  @override
  void dispose() {
    _appCell.dispose();
    _navbarCell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Navigation bar
          NavbarWidget(
            bus: widget.bus,
            currentScreen: _currentScreen,
            onScreenChanged: (screenId) {
              // The navbar widget will handle the bus communication
              // This callback is just for immediate UI feedback
              setState(() {
                _currentScreen = screenId;
              });
            },
          ),

          // Screen content
          Expanded(
            child: _buildCurrentScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 'screen_home':
        return HomeScreenWidget(bus: widget.bus);
      case 'screen_monitor':
        return MonitorScreenWidget(bus: widget.bus);
      default:
        return _buildUnknownScreen();
    }
  }

  Widget _buildUnknownScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Unknown Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Screen ID: $_currentScreen',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final envelope = Envelope.newRequest(
                service: 'navigation',
                verb: 'set_screen',
                schema: 'navigation.set_screen.v1',
                payload: {'screen_id': 'screen_home'},
              );
              await widget.bus.request(envelope);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
            ),
            child: const Text(
              'Go to Home',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
