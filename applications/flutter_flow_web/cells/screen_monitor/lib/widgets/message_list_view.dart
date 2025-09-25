import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bus message list display widget
class MessageListView extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final bool isPaused;

  const MessageListView({
    super.key,
    required this.messages,
    required this.isPaused,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedIndex;

  @override
  void didUpdateWidget(MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new messages arrive (if not paused)
    if (!widget.isPaused && widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.messages.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.message,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Bus Messages',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.isPaused)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PAUSED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                final isExpanded = _expandedIndex == index;
                
                return _buildMessageItem(context, message, index, isExpanded);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Container(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bus messages will appear here in real-time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    Map<String, dynamic> message,
    int index,
    bool isExpanded,
  ) {
    final theme = Theme.of(context);
    final timestamp = message['timestamp'] as String? ?? '';
    final subject = message['subject'] as String? ?? '';
    final service = message['service'] as String? ?? '';
    final verb = message['verb'] as String? ?? '';
    // final payload = message['payload'] as Map<String, dynamic>? ?? {};
    
    // Determine message color based on type
    final messageColor = _getMessageColor(context, subject, service);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            _expandedIndex = isExpanded ? null : index;
          }),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: messageColor.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(8),
              color: isExpanded 
                ? messageColor.withValues(alpha: 0.05)
                : Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message header
                Row(
                  children: [
                    // Timestamp
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatTimestamp(timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Service.verb
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: messageColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$service.$verb',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: messageColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Expand icon
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Subject
                Text(
                  subject,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                
                // Expanded content
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  _buildExpandedContent(context, message),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, Map<String, dynamic> message) {
    final theme = Theme.of(context);
    final payload = message['payload'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Payload',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyToClipboard(context, message),
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Copy message',
                style: IconButton.styleFrom(
                  minimumSize: const Size(24, 24),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              _formatJson(payload),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMessageColor(BuildContext context, String subject, String service) {
    final theme = Theme.of(context);
    
    if (subject.contains('error') || service.contains('error')) {
      return theme.colorScheme.error;
    } else if (service.contains('ui') || service.contains('flow')) {
      return Colors.blue;
    } else if (service.contains('logic') || service.contains('process')) {
      return Colors.green;
    }
    
    return theme.colorScheme.primary;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:'
             '${dt.minute.toString().padLeft(2, '0')}:'
             '${dt.second.toString().padLeft(2, '0')}'
             '.${dt.millisecond.toString().padLeft(3, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    if (json.isEmpty) return '{}';
    
    try {
      // Simple JSON formatting
      final buffer = StringBuffer();
      buffer.writeln('{');
      
      final entries = json.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;
        
        buffer.write('  "${entry.key}": ');
        if (entry.value is String) {
          buffer.write('"${entry.value}"');
        } else {
          buffer.write('${entry.value}');
        }
        
        if (!isLast) buffer.write(',');
        buffer.writeln();
      }
      
      buffer.write('}');
      return buffer.toString();
    } catch (e) {
      return json.toString();
    }
  }

  void _copyToClipboard(BuildContext context, Map<String, dynamic> message) {
    final text = _formatJson(message);
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
