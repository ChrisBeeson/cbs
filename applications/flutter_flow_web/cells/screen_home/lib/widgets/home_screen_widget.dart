import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';

/// Home screen widget displaying the main application content
class HomeScreenWidget extends StatefulWidget {
  final BodyBus? bus;

  const HomeScreenWidget({Key? key, this.bus}) : super(key: key);

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  String _flowContent = 'Flow';

  @override
  void initState() {
    super.initState();
    _subscribeToFlowTextUpdates();
  }

  Future<void> _subscribeToFlowTextUpdates() async {
    if (widget.bus != null) {
      // Subscribe to flow text content updates
      await widget.bus!.subscribe('cbs.flow_text.content_ready', (envelope) async {
        if (mounted) {
          final content = envelope.payload?['content'] as String?;
          if (content != null) {
            setState(() {
              _flowContent = content;
            });
          }
        }
        return {'status': 'handled'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'Welcome to CBS',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00D4FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cell Body System - Web Application',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Flow text display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Flow Content',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00D4FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _flowContent,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D4FF),
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionCard(
                  title: 'Bus Monitor',
                  description: 'View real-time bus messages',
                  icon: Icons.monitor,
                  onTap: () => _navigateToMonitor(),
                ),
                const SizedBox(width: 24),
                _buildActionCard(
                  title: 'System Status',
                  description: 'Check cell health',
                  icon: Icons.health_and_safety,
                  onTap: () => _showSystemStatus(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: const Color(0xFF00D4FF),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToMonitor() async {
    if (widget.bus != null) {
      final envelope = Envelope.newRequest(
        service: 'navigation',
        verb: 'set_screen',
        schema: 'navigation.set_screen.v1',
        payload: {'screen_id': 'screen_monitor'},
      );
      await widget.bus!.request(envelope);
    }
  }

  void _showSystemStatus() {
    // Show system status dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'System Status',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'All cells are operating normally.\nBus communication is active.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00D4FF)),
            ),
          ),
        ],
      ),
    );
  }
}
