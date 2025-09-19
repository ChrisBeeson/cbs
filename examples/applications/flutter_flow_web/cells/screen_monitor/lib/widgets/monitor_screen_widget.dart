import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import 'message_list_view.dart';

/// Monitor screen widget displaying bus monitor interface
class MonitorScreenWidget extends StatefulWidget {
  final BodyBus? bus;

  const MonitorScreenWidget({Key? key, this.bus}) : super(key: key);

  @override
  State<MonitorScreenWidget> createState() => _MonitorScreenWidgetState();
}

class _MonitorScreenWidgetState extends State<MonitorScreenWidget> {
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _subscribeToBusMessages();
  }

  Future<void> _subscribeToBusMessages() async {
    if (widget.bus != null) {
      // Subscribe to bus monitor message updates
      await widget.bus!.subscribe('cbs.bus_monitor.messages_updated', (envelope) async {
        if (mounted) {
          setState(() {
            _messages = List<Map<String, dynamic>>.from(envelope.payload?['messages'] ?? []);
          });
        }
        return {'status': 'handled'};
      });

      // Request current messages
      await _requestBusMessages();
    }
  }

  Future<void> _requestBusMessages() async {
    if (widget.bus != null) {
      try {
        final envelope = Envelope.newRequest(
          service: 'bus_monitor',
          verb: 'get_messages',
          schema: 'bus_monitor.get_messages.v1',
          payload: {},
        );
        await widget.bus!.request(envelope);
      } catch (e) {
        print('\x1B[33m[WARN] ${DateTime.now().toIso8601String()} [MonitorScreenWidget] '
              'Failed to request bus messages: $e\x1B[0m');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monitor,
                  color: const Color(0xFF00D4FF),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus Monitor',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    Text(
                      'Real-time CBS message monitoring',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${_messages.length} messages',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _clearMessages,
                  icon: const Icon(Icons.clear_all, color: Colors.white),
                  label: const Text('Clear', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    side: BorderSide(
                      color: Colors.red.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : MessageListView(
                    messages: _messages,
                    isPaused: false,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages captured yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bus messages will appear here in real-time',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearMessages() async {
    if (widget.bus != null) {
      try {
        final envelope = Envelope.newRequest(
          service: 'bus_monitor',
          verb: 'clear',
          schema: 'bus_monitor.clear.v1',
          payload: {
            'user_initiated': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        await widget.bus!.request(envelope);
      } catch (e) {
        print('\x1B[33m[WARN] ${DateTime.now().toIso8601String()} [MonitorScreenWidget] '
              'Failed to clear messages: $e\x1B[0m');
      }
    }
  }
}
