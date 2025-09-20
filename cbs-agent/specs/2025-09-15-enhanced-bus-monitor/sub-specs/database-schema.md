# Database Schema

This is the database schema implementation for the spec detailed in @cbs-agent/specs/2025-09-15-enhanced-bus-monitor/spec.md

## Cell-Internal Description Storage

Since the BusMonitorCell operates in complete isolation and only communicates through the bus, the description registry will be implemented as a static lookup within the cell itself. However, for extensibility and future dynamic description loading, a database schema is provided for optional use.

## Optional Schema Registry Table

### New Table: message_schemas (Optional)

This table would only be used if the BusMonitorCell is enhanced to load descriptions dynamically via a separate service cell that manages schema information.

```sql
CREATE TABLE message_schemas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service TEXT NOT NULL,
    verb TEXT NOT NULL,
    schema_version TEXT NOT NULL,
    payload_type TEXT,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(service, verb, schema_version)
);
```

### Indexes

```sql
CREATE INDEX idx_message_schemas_service_verb 
ON message_schemas(service, verb);

CREATE INDEX idx_message_schemas_lookup 
ON message_schemas(service, verb, schema_version);
```

### Initial Data Population

```sql
INSERT INTO message_schemas (service, verb, schema_version, payload_type, description) VALUES
('greeter', 'say_hello', 'v1', 'Name', 'Processes user name input for greeting generation'),
('greeter', 'get_greeting', 'v1', 'Greeting', 'Retrieves personalized greeting message'),
('monitor', 'capture', 'v1', 'MessageCapture', 'Captures and logs bus message for system monitoring'),
('flow', 'toggle_visibility', 'v1', 'VisibilityState', 'Controls visibility state of flow text component'),
('bus_monitor', 'capture', 'v1', 'BusMessage', 'Records bus message for real-time monitoring display');
```

## CBS Cell Architecture Considerations

### Primary Implementation: Static Registry
- **Cell-Internal**: Description mapping hardcoded within BusMonitorCell
- **No Database Dependency**: Cell operates independently without external storage
- **Bus-Only Communication**: No direct database access from the cell
- **Isolation Maintained**: Cell can be added/removed without affecting database

### Future Enhancement: Dynamic Registry via Service Cell
If dynamic description loading is desired, it would be implemented as:

1. **Separate SchemaRegistryCell**: New cell that manages schema descriptions
2. **Bus Communication**: BusMonitorCell requests descriptions via bus messages
3. **Database Access**: SchemaRegistryCell handles all database operations
4. **Cell Isolation**: Both cells remain isolated, communicating only through bus

**Example Bus Message Flow:**
```
BusMonitorCell -> bus.request('cbs.schema_registry.get_description') -> SchemaRegistryCell
SchemaRegistryCell -> database query -> bus.response() -> BusMonitorCell
```

## Migration Script (Future Use)

```sql
-- Migration: Add message schema registry (for future SchemaRegistryCell)
-- Version: 001_create_message_schemas
-- Date: 2025-09-15

BEGIN;

CREATE TABLE IF NOT EXISTS message_schemas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service TEXT NOT NULL,
    verb TEXT NOT NULL,
    schema_version TEXT NOT NULL,
    payload_type TEXT,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(service, verb, schema_version)
);

CREATE INDEX IF NOT EXISTS idx_message_schemas_service_verb 
ON message_schemas(service, verb);

CREATE INDEX IF NOT EXISTS idx_message_schemas_lookup 
ON message_schemas(service, verb, schema_version);

-- Insert initial schema descriptions
INSERT INTO message_schemas (service, verb, schema_version, payload_type, description) VALUES
('greeter', 'say_hello', 'v1', 'Name', 'Processes user name input for greeting generation'),
('greeter', 'get_greeting', 'v1', 'Greeting', 'Retrieves personalized greeting message'),
('monitor', 'capture', 'v1', 'MessageCapture', 'Captures and logs bus message for system monitoring'),
('flow', 'toggle_visibility', 'v1', 'VisibilityState', 'Controls visibility state of flow text component'),
('bus_monitor', 'capture', 'v1', 'BusMessage', 'Records bus message for real-time monitoring display')
ON CONFLICT (service, verb, schema_version) DO NOTHING;

COMMIT;
```

## Rationale

### Cell Isolation Priority
- **Primary**: Static description registry within BusMonitorCell maintains isolation
- **Secondary**: Database schema provided for future extensibility via separate service cell
- **Architecture Compliance**: All database access would go through dedicated cells, not direct from BusMonitorCell

### Performance Considerations
- **Static Registry**: Fastest lookup, no network/database overhead
- **Future Dynamic**: If implemented, would use bus message caching within BusMonitorCell
- **Cell Independence**: BusMonitorCell functions with or without external description services
