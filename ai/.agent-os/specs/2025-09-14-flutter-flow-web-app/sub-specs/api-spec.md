# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-09-14-flutter-flow-web-app/spec.md

## Endpoints

### GET /api/health
**Purpose:** Health check endpoint for CBS system status
**Parameters:** None
**Response:** 
```json
{
  "status": "healthy",
  "timestamp": "2025-09-14T12:00:00Z",
  "version": "0.1.0"
}
```
**Errors:** 
- 503 Service Unavailable: System is starting up or shutting down

### POST /api/cbs/request
**Purpose:** Send CBS envelope request to the message bus
**Parameters:** 
- Body: CBS Envelope JSON
```json
{
  "id": "uuid",
  "service": "string",
  "verb": "string", 
  "schema": "string",
  "payload": {}
}
```
**Response:**
```json
{
  "id": "uuid",
  "service": "string",
  "verb": "string",
  "schema": "string",
  "payload": {},
  "error": null
}
```
**Errors:**
- 400 Bad Request: Invalid envelope format
- 404 Not Found: No handler for specified service/verb
- 408 Request Timeout: Handler did not respond within timeout
- 500 Internal Server Error: Handler execution failed

### GET /api/cbs/subjects
**Purpose:** List all registered CBS subjects and their handlers
**Parameters:** None
**Response:**
```json
{
  "subjects": [
    {
      "subject": "cbs.flow_ui.render",
      "queue_group": "flow_ui",
      "cell_id": "flutter_flow_ui"
    }
  ]
}
```
**Errors:**
- 500 Internal Server Error: Failed to retrieve subject list

### WebSocket /ws/cbs
**Purpose:** Real-time bidirectional communication with CBS message bus
**Protocol:** WebSocket with JSON message format
**Message Format:**
```json
{
  "type": "request|response|error",
  "envelope": {
    "id": "uuid",
    "service": "string", 
    "verb": "string",
    "schema": "string",
    "payload": {}
  }
}
```
**Connection Flow:**
1. Client establishes WebSocket connection
2. Client sends request messages
3. Server processes via CBS message bus
4. Server sends response messages
5. Connection maintained for real-time updates

### GET /api/config/body-spec
**Purpose:** Retrieve current body specification configuration
**Parameters:** None
**Response:**
```json
{
  "application_name": "flutter_flow_web_app",
  "version": "0.1.0",
  "cells": [
    {
      "id": "flutter_flow_ui",
      "language": "dart",
      "path": "cells/flutter/ui/flow_ui"
    }
  ]
}
```
**Errors:**
- 500 Internal Server Error: Failed to read configuration

### PUT /api/config/body-spec
**Purpose:** Update body specification configuration and reload application
**Parameters:**
- Body: Body spec configuration JSON
```json
{
  "application_name": "string",
  "version": "string", 
  "cells": [
    {
      "id": "string",
      "language": "rust|dart|python",
      "path": "string"
    }
  ]
}
```
**Response:**
```json
{
  "status": "reloading",
  "message": "Configuration updated, reloading cells..."
}
```
**Errors:**
- 400 Bad Request: Invalid configuration format
- 422 Unprocessable Entity: Configuration validation failed
- 500 Internal Server Error: Failed to apply configuration

## Controllers

### HealthController
**Actions:**
- `health_check`: Returns system status and version information
**Business Logic:** 
- Check CBS message bus connectivity
- Validate all registered cells are responsive
- Return aggregated health status
**Error Handling:**
- Graceful degradation when components are unavailable
- Detailed error messages for debugging

### CBSController  
**Actions:**
- `request`: Process CBS envelope requests
- `list_subjects`: Return registered subjects and handlers
**Business Logic:**
- Validate envelope format and required fields
- Route requests to appropriate message bus handlers
- Handle timeouts and error responses
- Maintain request/response correlation
**Error Handling:**
- Envelope validation with detailed error messages
- Timeout handling with configurable limits
- Error envelope generation for failed requests

### WebSocketController
**Actions:**
- `handle_connection`: Manage WebSocket connections
- `process_message`: Handle incoming WebSocket messages
- `broadcast_response`: Send responses to connected clients
**Business Logic:**
- Maintain client connection registry
- Route messages through CBS message bus
- Handle connection lifecycle (connect/disconnect)
- Support real-time bidirectional communication
**Error Handling:**
- Connection error recovery
- Message format validation
- Graceful connection termination

### ConfigController
**Actions:**
- `get_body_spec`: Retrieve current configuration
- `update_body_spec`: Update and reload configuration
**Business Logic:**
- Read/write body spec YAML files
- Validate configuration schema
- Trigger cell reload process
- Maintain configuration versioning
**Error Handling:**
- Configuration validation with detailed errors
- Rollback on failed configuration updates
- Safe reload with fallback to previous configuration

## Purpose

These API endpoints enable Flutter web applications to integrate seamlessly with the CBS message bus architecture. The HTTP endpoints provide standard request/response patterns, while WebSocket support enables real-time communication for interactive applications. The configuration endpoints allow dynamic application switching without system restarts, supporting the core requirement of configurable CBS applications.
