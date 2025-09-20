# API Specification

API spec for `@cbs-agent/specs/2025-09-14-flutter-flow-web-app/spec.md`.

## Endpoints

### GET /api/health
**Purpose:** Health check
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
- 503 Service Unavailable

### POST /api/cbs/request
**Purpose:** Send CBS envelope request to bus
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
- 400 Bad Request
- 404 Not Found
- 408 Request Timeout
- 500 Internal Server Error

### GET /api/cbs/subjects
**Purpose:** List registered CBS subjects
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
- 500 Internal Server Error

### WebSocket /ws/cbs
**Purpose:** Real-time bidirectional communication
**Protocol:** WebSocket JSON
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
1. Client connects
2. Client sends requests
3. Server routes via CBS bus
4. Server sends responses
5. Connection stays open for updates

### GET /api/config/body-spec
**Purpose:** Retrieve current body spec config
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
- 500 Internal Server Error

### PUT /api/config/body-spec
**Purpose:** Update body spec config and reload
**Parameters:**
- Body: Body spec JSON
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
- 400 Bad Request
- 422 Unprocessable Entity
- 500 Internal Server Error

## Controllers

### HealthController
- `health_check`: Returns system status and version
- Checks bus connectivity and cell responsiveness

### CBSController  
- `request`: Process envelope requests
- `list_subjects`: Return subjects/handlers
- Validates envelopes; routes; handles timeouts/errors

### WebSocketController
- `handle_connection`, `process_message`, `broadcast_response`
- Manages connections and routes via bus

### ConfigController
- `get_body_spec`, `update_body_spec`
- Reads/writes YAML; validates; triggers reload; versioning; rollback on failure

## Purpose

These endpoints let Flutter web apps integrate with CBS. HTTP covers request/response; WebSocket covers real-time. Config endpoints support dynamic app switching without restarts.
