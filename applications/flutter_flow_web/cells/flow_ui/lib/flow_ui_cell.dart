import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';
import 'package:bus_monitor_cell/bus_monitor_cell.dart';
import 'package:flow_text_cell/flow_text_widget.dart';

/// Flow UI Cell - orchestrates bus monitor and flow text cells
class FlowUICell implements Cell {
  final BusMonitorCell _busMonitorCell = BusMonitorCell();
  final FlowTextCell _flowTextCell = FlowTextCell();
  bool _disposed = false;

  @override
  String get id => 'flow_ui';

  @override
  List<String> get subjects => ['cbs.flow_ui.render'];

  /// Get bus monitor cell instance
  BusMonitorCell get busMonitorCell => _busMonitorCell;

  /// Get flow text cell instance
  FlowTextCell get flowTextCell => _flowTextCell;

  @override
  Future<void> register(BodyBus bus) async {
    if (_disposed) return;
    
    await bus.subscribe('cbs.flow_ui.render', _handleRender);
    await _busMonitorCell.register(bus);
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

  /// Toggle flow text visibility
  void toggleFlowText() {
    if (!_disposed) {
      _flowTextCell.toggleVisibility();
    }
  }

  /// Clear all bus messages
  void clearMessages() {
    if (!_disposed) {
      _busMonitorCell.clearMessages();
    }
  }

  /// Dispose resources
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    _busMonitorCell.dispose();
    _flowTextCell.dispose();
    print('\x1B[32m[INFO] ${DateTime.now().toIso8601String()} [FlowUICell] '
          'Cell disposed\x1B[0m');
  }
}

/// Flutter widget with split layout integrating flow text and bus monitor
class FlowUIWidget extends StatefulWidget {
  const FlowUIWidget({Key? key}) : super(key: key);

  @override
  State<FlowUIWidget> createState() => _FlowUIWidgetState();
}

class _FlowUIWidgetState extends State<FlowUIWidget> {
  final FlowUICell _flowUICell = FlowUICell();

  @override
  void dispose() {
    _flowUICell.dispose();
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
                  ValueListenableBuilder<bool>(
                    valueListenable: _flowUICell.flowTextCell.visibilityNotifier,
                    builder: (context, isVisible, child) {
                      return Column(
                        children: [
                          FlowTextWidget(visible: isVisible),
                          const SizedBox(height: 32),
                          _buildToggleButton(isVisible),
                        ],
                      );
                    },
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
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
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
      onPressed: () => _flowUICell.toggleFlowText(),
      icon: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.white,
      ),
      label: Text(
        isVisible ? 'Hide' : 'Show',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00D4FF).withOpacity(0.2),
        foregroundColor: Colors.white,
        side: BorderSide(
          color: const Color(0xFF00D4FF).withOpacity(0.5),
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
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ValueListenableBuilder<List<BusMessage>>(
              valueListenable: _flowUICell.busMonitorCell.messages,
              builder: (context, messages, child) {
                return Text(
                  'Messages (${messages.length})',
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _flowUICell.clearMessages(),
            icon: const Icon(Icons.clear_all, size: 16, color: Colors.white),
            label: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.red.withOpacity(0.5),
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
    return ValueListenableBuilder<List<BusMessage>>(
      valueListenable: _flowUICell.busMonitorCell.messages,
      builder: (context, messages, child) {
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _flowUICell.busMonitorCell.scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageItem(message);
          },
        );
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
  Widget _buildMessageItem(BusMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: message.displayColor.withOpacity(0.3),
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
                '${message.envelope.service}.${message.envelope.verb}',
                style: TextStyle(
                  color: message.displayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                message.formattedTimestamp,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Schema: ${message.envelope.schema}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          if (message.envelope.isError) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${message.envelope.error?.message}',
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
