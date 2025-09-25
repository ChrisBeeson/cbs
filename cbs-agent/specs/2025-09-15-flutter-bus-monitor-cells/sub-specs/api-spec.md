# API Specification

This is the API specification for the spec detailed in @cbs-agent/specs/2025-09-15-flutter-bus-monitor-cells/spec.md

## CBS Bus Integration

### Bus Monitor Cell Registration

**Subject Subscription:** `cbs.>`
**Queue Group:** `bus_monitor`
**Purpose:** Subscribe to all CBS messages using NATS wildcard pattern for system-wide monitoring

**Message Handler:**
```dart
Future<Map<String, dynamic>> _handleAllMessages(Envelope envelope)
```
**Parameters:** CBS Envelope containing service, verb, payload, and metadata
**Response:** Status confirmation with message ID and timestamp
**Behavior:** Captures message, updates UI list, logs activity

### Flow Text Cell Interface

**Visibility Control:**
- `toggleVisibility()` - Toggle current visibility state
- `setVisibility(bool visible)` - Set explicit visibility state  
- `bool get isVisible` - Get current visibility state

**Widget Interface:**
```dart
FlowTextWidget({
  bool visible = true,
  double? fontSize,
  Color? color,
  Color? glowColor,
  double letterSpacing = 4.0,
  List<Shadow>? customShadows,
})
```

## CBS Envelope Schema

### Bus Monitor Message Capture

**Input Envelope Format:**
```json
{
  "id": "uuid-string",
  "service": "service-name",
  "verb": "action-name", 
  "schema": "service/version",
  "payload": {
    "data": "message-specific-content"
  }
}
```

**Response Envelope Format:**
```json
{
  "id": "original-message-uuid",
  "service": "bus_monitor",
  "verb": "capture",
  "schema": "monitor/v1",
  "payload": {
    "status": "captured",
    "message_id": "original-message-uuid",
    "timestamp": "2025-09-15T10:30:00.000Z"
  }
}
```

### Error Handling

**Connection Errors:**
```json
{
  "id": "request-uuid",
  "service": "bus_monitor", 
  "verb": "capture",
  "schema": "monitor/v1",
  "error": {
    "code": "ConnectionError",
    "message": "Failed to connect to CBS bus",
    "details": {
      "bus_url": "connection-endpoint",
      "retry_count": 3
    }
  }
}
```

**Message Parse Errors:**
```json
{
  "id": "request-uuid",
  "service": "bus_monitor",
  "verb": "capture", 
  "schema": "monitor/v1",
  "error": {
    "code": "ParseError",
    "message": "Invalid envelope format",
    "details": {
      "raw_message": "original-message-data",
      "parse_error": "specific-parsing-issue"
    }
  }
}
```

## Flutter Widget Events

### Flow Text Toggle Events

**Toggle Button Press:**
- Triggers `FlowTextCell.toggleVisibility()`
- Updates `ValueNotifier<bool>` state
- Logs visibility change with debug level
- Updates button icon (visibility/visibility_off)

**Clear Messages Button Press:**
- Triggers `BusMonitorCell.clearMessages()`
- Resets message list and notifier
- Logs clear action with info level
- Updates message count display to 0

### Reactive State Updates

**Message List Updates:**
- New messages trigger `ValueNotifier<List<BusMessage>>` update
- UI automatically rebuilds ListView.builder
- Auto-scroll animation to bottom
- Message count badge updates

**Visibility State Updates:**
- Toggle changes trigger `ValueNotifier<bool>` update  
- FlowTextWidget rebuilds with new visibility
- Button icon and text update reactively
- Smooth show/hide transitions
