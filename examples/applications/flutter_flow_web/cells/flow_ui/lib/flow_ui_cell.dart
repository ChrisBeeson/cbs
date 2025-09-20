import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import 'package:flow_text_cell/flow_text_widget.dart';

/// Log shim for cell-level logging
class _LogShim {
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';

  static void i(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_green[INFO] $ts $message$_reset');
  }

  static void e(String message) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$_red[ERROR] $ts $message$_reset');
  }
}

/// Flow UI Cell - coordinates UI rendering through bus messages only
class FlowUICell implements Cell {
  BodyBus? _bus;
  bool _disposed = false;

  @override
  String get id => 'flow_ui';

  @override
  List<String> get subjects => [
    'cbs.flow_ui.render',
    'cbs.flow_ui.toggle_flow_text',
    'cbs.flow_ui.clear_messages'
  ];

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    
    _bus = bus;
    await bus.subscribe('cbs.flow_ui.render', _handleRender);
    await bus.subscribe('cbs.flow_ui.toggle_flow_text', _handleToggleFlowText);
    await bus.subscribe('cbs.flow_ui.clear_messages', _handleClearMessages);
    
    _LogShim.i('[FlowUICell] registered with bus');
  }

  /// Handle render requests
  Future<Map<String, dynamic>> _handleRender(Envelope envelope) async {
    return handleRender(envelope);
  }

  /// Public method for handling render requests (for testing)
  Future<Map<String, dynamic>> handleRender(dynamic envelope) async {
    if (_disposed) {
      return {
        'status': 'error',
        'message': 'Cell is disposed',
      };
    }

    return {
      'status': 'rendered',
      'component': 'flow',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Handle toggle flow text request via bus
  Future<Map<String, dynamic>> _handleToggleFlowText(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      // Send bus message to toggle flow text
      final toggleEnvelope = Envelope.newRequest(
        service: 'flow_text',
        verb: 'toggle_visibility',
        schema: 'flow_text.toggle_visibility.v1',
        payload: {},
      );

      await _bus?.request(toggleEnvelope);

      // Send bus message about the toggle action
      final responseEnvelope = Envelope.newRequest(
        service: 'flow_ui',
        verb: 'toggle',
        schema: 'flow_ui.toggle.v1',
        payload: {
          'action': 'visibility_toggle',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _bus?.request(responseEnvelope);

      return {
        'status': 'success',
        'action': 'toggle_flow_text',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _LogShim.e('[FlowUICell] toggle_flow_text error: $e');
      return _errorResponse('Failed to toggle flow text: $e');
    }
  }

  /// Handle clear messages request via bus
  Future<Map<String, dynamic>> _handleClearMessages(Envelope envelope) async {
    if (_disposed) return _errorResponse('Cell is disposed');

    try {
      // Send bus message to clear bus monitor
      final clearEnvelope = Envelope.newRequest(
        service: 'bus_monitor',
        verb: 'clear',
        schema: 'bus_monitor.clear.v1',
        payload: {
          'action': 'messages_cleared',
          'timestamp': DateTime.now().toIso8601String(),
          'user_initiated': true,
        },
      );

      await _bus?.request(clearEnvelope);

      return {
        'status': 'success',
        'action': 'clear_messages',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _LogShim.e('[FlowUICell] clear_messages error: $e');
      return _errorResponse('Failed to clear messages: $e');
    }
  }

  /// Helper to create error response
  Map<String, dynamic> _errorResponse(String message) {
    return {
      'status': 'error',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    _LogShim.i('[FlowUICell] disposed');
  }
}

/// Flutter widget with split layout integrating flow text and bus monitor
/// This widget communicates with cells through bus messages only
class FlowUIWidget extends StatefulWidget {
  final BodyBus? bus;
  
  const FlowUIWidget({Key? key, this.bus}) : super(key: key);

  @override
  State<FlowUIWidget> createState() => _FlowUIWidgetState();
}

class _FlowUIWidgetState extends State<FlowUIWidget> {
  final FlowUICell _flowUICell = FlowUICell();
  BodyBus? _bus;
  
  // State for flow text visibility (managed through bus messages)
  bool _flowTextVisible = true;
  
  // State for bus messages (managed through bus messages)
  List<Map<String, dynamic>> _busMessages = [];

  @override
  void initState() {
    super.initState();
    _bus = widget.bus;
    _initializeCells();
    _subscribeToUpdates();
  }

  Future<void> _initializeCells() async {
    if (_bus != null) {
      await _flowUICell.register(_bus!);
      print('\x1B[32m[INFO] ${DateTime.now().toIso8601String()} [FlowUIWidget] '
            'Cells registered with bus\x1B[0m');
    }
  }

  /// Subscribe to bus messages to update widget state
  Future<void> _subscribeToUpdates() async {
    if (_bus != null) {
      // Subscribe to flow text visibility changes
      await _bus!.subscribe('cbs.flow_text.visibility_changed', (envelope) async {
        if (mounted) {
          setState(() {
            _flowTextVisible = envelope.payload?['visible'] ?? true;
          });
        }
        return {'status': 'handled'};
      });
      
      // Subscribe to bus monitor message updates
      await _bus!.subscribe('cbs.bus_monitor.messages_updated', (envelope) async {
        if (mounted) {
          setState(() {
            _busMessages = List<Map<String, dynamic>>.from(envelope.payload?['messages'] ?? []);
          });
        }
        return {'status': 'handled'};
      });
    }
  }

  /// Handle toggle button press with bus messaging only
  Future<void> _handleTogglePress(bool currentlyVisible) async {
    if (_bus != null) {
      final envelope = Envelope.newRequest(
        service: 'flow_ui',
        verb: 'toggle_flow_text',
        schema: 'flow_ui.toggle_flow_text.v1',
        payload: {
          'previous_state': currentlyVisible,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      try {
        await _bus!.request(envelope);
      } catch (e) {
        print('\x1B[33m[WARN] ${DateTime.now().toIso8601String()} [FlowUIWidget] '
              'Could not send toggle message: $e\x1B[0m');
      }
    }
  }

  /// Handle clear messages button press with bus messaging only
  Future<void> _handleClearMessages() async {
    if (_bus != null) {
      final envelope = Envelope.newRequest(
        service: 'flow_ui',
        verb: 'clear_messages',
        schema: 'flow_ui.clear_messages.v1',
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'user_initiated': true,
        },
      );
      
      try {
        await _bus!.request(envelope);
      } catch (e) {
        print('\x1B[33m[WARN] ${DateTime.now().toIso8601String()} [FlowUIWidget] '
              'Could not send clear message: $e\x1B[0m');
      }
    }
  }

  @override
  void dispose() {
    _flowUICell.dispose();
    _bus?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Row(
        children: [
          // Left side - Flow Text
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flow Text with toggle controls
                  Column(
                    children: [
                      FlowTextWidget(visible: _flowTextVisible),
                      const SizedBox(height: 32),
                      _buildToggleButton(_flowTextVisible),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right side - Bus Monitor
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  _buildMessageHeader(),
                  Expanded(
                    child: _buildMessageList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build toggle button for flow text visibility
  Widget _buildToggleButton(bool isVisible) {
    return ElevatedButton.icon(
      onPressed: () => _handleTogglePress(isVisible),
      icon: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.white,
      ),
      label: Text(
        isVisible ? 'Hide' : 'Show',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00D4FF).withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        side: BorderSide(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  /// Build message header with count and clear button
  Widget _buildMessageHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Messages (${_busMessages.length})',
              style: const TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _handleClearMessages(),
            icon: const Icon(Icons.clear_all, size: 16, color: Colors.white),
            label: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.red.withValues(alpha: 0.5),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  /// Build message list with empty state
  Widget _buildMessageList() {
    if (_busMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _busMessages.length,
      itemBuilder: (context, index) {
        final message = _busMessages[index];
        return _buildMessageItem(message);
      },
    );
  }

  /// Build empty state when no messages
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.white38,
          ),
          SizedBox(height: 16),
          Text(
            'No messages captured yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
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

  /// Build individual message item
  Widget _buildMessageItem(Map<String, dynamic> message) {
    final service = message['service'] ?? 'unknown';
    final verb = message['verb'] ?? 'unknown';
    final schema = message['schema'] ?? 'unknown';
    final timestamp = message['timestamp'] ?? '';
    final isError = message['is_error'] ?? false;
    final error = message['error'];
    
    // Simple color coding based on service type
    Color displayColor = Colors.white70;
    if (service.contains('ui') || service.contains('screen')) {
      displayColor = Colors.blue;
    } else if (service.contains('logic') || service.contains('navigation')) {
      displayColor = Colors.green;
    } else if (isError) {
      displayColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: displayColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$service.$verb',
                style: TextStyle(
                  color: displayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                timestamp,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Schema: $schema',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          if (isError && error != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: $error',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

