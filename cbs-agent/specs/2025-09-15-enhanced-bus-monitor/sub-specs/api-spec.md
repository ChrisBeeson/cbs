# API Specification

This is the API specification for the spec detailed in @cbs-agent/specs/2025-09-15-enhanced-bus-monitor/spec.md

## CBS Cell Interface Compliance

### BusMonitorCell Implementation

**Cell Trait Implementation:**
```dart
class BusMonitorCell implements Cell {
  @override
  String get id => 'bus_monitor';
  
  @override
  List<String> get subjects => ['cbs.>'];
  
  @override
  Future<void> register(BodyBus bus) async {
    await bus.subscribe('cbs.>', _handleAllMessages);
  }
  
  Future<Map<String, dynamic>> _handleAllMessages(Envelope envelope) async {
    // Process captured message within cell
    return await handleMessage(envelope);
  }
}
```

**Cell Registration by Body:**
- Body instantiates BusMonitorCell
- Body calls `cell.register(bus)` to subscribe to subjects
- Cell operates independently via bus messages only

## Enhanced CBS Envelope Schema

### Updated Envelope Structure

**Enhanced Envelope Format:**
```json
{
  "id": "uuid-string",
  "service": "service-name",
  "verb": "action-name", 
  "schema": "service/v1/PayloadType",
  "payload": {
    "data": "message-specific-content"
  },
  "description": "Human-readable description of what this message does"
}
```

**New Fields:**
- `description` (optional): Human-readable explanation of the message purpose
- Enhanced `schema` parsing: Extract payload type from `service/version/PayloadType` format

### Channel Information Extraction (Within Cell)

**Subject Derivation:**
```dart
String get channel => envelope.subject(); // Returns 'cbs.service.verb'
```

**Channel Display Format:**
- Full channel: `cbs.greeter.say_hello`
- Service context: `greeter`
- Action context: `say_hello`

### Payload Type Detection (Cell-Internal)

**Schema Parsing Logic (Within BusMonitorCell):**
```dart
class SchemaInfo {
  final String service;
  final String version;
  final String payloadType;
  
  factory SchemaInfo.fromSchema(String schema) {
    // Parse "greeter/v1/Name" format
    final parts = schema.split('/');
    return SchemaInfo(
      service: parts[0],
      version: parts[1], 
      payloadType: parts.length > 2 ? parts[2] : 'Unknown'
    );
  }
}
```

**Payload Type Examples:**
- `greeter/v1/Name` → Type: "Name"
- `monitor/v1/Status` → Type: "Status" 
- `error/v1/ErrorDetails` → Type: "ErrorDetails"

## Description Registry (Cell-Internal)

### Static Description Mapping Within BusMonitorCell

**Service Description Registry:**
```dart
class MessageDescriptionRegistry {
  static const Map<String, String> descriptions = {
    'greeter.say_hello': 'Processes user name input for greeting generation',
    'greeter.get_greeting': 'Retrieves personalized greeting message',
    'monitor.capture': 'Captures and logs bus message for system monitoring',
    'flow.toggle_visibility': 'Controls visibility state of flow text component',
  };
  
  static String getDescription(String service, String verb) {
    return descriptions['$service.$verb'] ?? 'CBS message processing';
  }
}
```

### Enhanced BusMessage Structure (Cell-Internal)

**Updated BusMessage Class:**
```dart
class BusMessage {
  final DateTime timestamp;
  final Envelope envelope;
  
  // New computed properties (within BusMonitorCell)
  String get channel => envelope.subject();
  String get payloadType => _extractPayloadType(envelope.schema);
  String get description => envelope.description ?? 
      MessageDescriptionRegistry.getDescription(envelope.service, envelope.verb);
  
  String _extractPayloadType(String schema) {
    final parts = schema.split('/');
    return parts.length > 2 ? parts[2] : 'Data';
  }
}
```

## Bus Message Flow

### Message Capture Process

1. **Other cells send messages** via `bus.request(envelope)` or `bus.subscribe()`
2. **Bus routes messages** through NATS to subscribers
3. **BusMonitorCell receives all messages** via `cbs.>` wildcard subscription
4. **Cell processes messages** internally and updates UI state
5. **No response required** - monitor cell captures passively

### Cell Isolation Guarantee

**Bus-Only Communication:**
- BusMonitorCell has no direct references to other cells
- Other cells have no knowledge of BusMonitorCell existence
- All communication flows through BodyBus message passing
- Cell can be removed/added without affecting other components

**Message Flow Example:**
```
GreeterCell -> bus.request() -> NATS -> BusMonitorCell.handleMessage()
LogicCell   -> bus.request() -> NATS -> BusMonitorCell.handleMessage()
FlowCell    -> bus.request() -> NATS -> BusMonitorCell.handleMessage()
```
