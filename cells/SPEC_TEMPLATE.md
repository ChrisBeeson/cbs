# Cell Specification Template

## Metadata

- **Cell ID**: `{cell_id}`
- **Name**: `{cell_name}`
- **Version**: `{version}`
- **Language**: `{language}` (Rust/Python/Dart)
- **Category**: `{category}` (io/logic/storage/integration)
- **Purpose**: {brief_description}

## Dependencies

### Runtime Dependencies
- {dependency_1}: {version}
- {dependency_2}: {version}

### Development Dependencies
- {dev_dependency_1}: {version}
- {dev_dependency_2}: {version}

## Interface

### Subjects
- **Primary Subject**: `cbs.{service}.{verb}`
- **Queue Group**: `{service}`
- **Additional Subjects**: (if any)
  - `cbs.{service}.{verb2}`

### Message Schemas

#### Input Schema
```json
{
  "id": "uuid",
  "service": "{service}",
  "verb": "{verb}",
  "schema": "{schema_reference}",
  "payload": {
    // Input payload structure
  }
}
```

#### Output Schema
```json
{
  "id": "uuid",
  "service": "{service}",
  "verb": "{verb}",
  "schema": "{response_schema_reference}",
  "payload": {
    // Output payload structure
  }
}
```

#### Error Schema
```json
{
  "id": "uuid",
  "service": "{service}",
  "verb": "{verb}",
  "schema": "{error_schema_reference}",
  "error": {
    "code": "{error_code}",
    "message": "{error_message}",
    "details": {
      // Additional error context
    }
  }
}
```

## Behavior

### Functional Requirements
1. {requirement_1}
2. {requirement_2}
3. {requirement_3}

### Edge Cases
- **Empty Input**: {behavior}
- **Invalid Input**: {behavior}
- **Network Timeout**: {behavior}
- **Resource Unavailable**: {behavior}

### Performance Expectations
- **Response Time**: {expected_response_time}
- **Throughput**: {expected_throughput}
- **Memory Usage**: {expected_memory_usage}
- **CPU Usage**: {expected_cpu_usage}

### Error Conditions
| Error Code | Condition | Response |
|------------|-----------|----------|
| `BAD_REQUEST` | Invalid input format | Return error with validation details |
| `NOT_FOUND` | Resource not found | Return error with resource identifier |
| `TIMEOUT` | Operation timeout | Return error with timeout details |
| `INTERNAL_ERROR` | Unexpected error | Return error with safe error message |

## Testing

### Unit Test Scenarios
1. **Valid Input Processing**
   - Input: {test_input}
   - Expected Output: {expected_output}
   - Assertions: {assertions}

2. **Invalid Input Handling**
   - Input: {invalid_input}
   - Expected Output: {error_response}
   - Assertions: {error_assertions}

3. **Edge Case Handling**
   - Input: {edge_case_input}
   - Expected Output: {edge_case_output}
   - Assertions: {edge_case_assertions}

### Integration Test Scenarios
1. **End-to-End Message Flow**
   - Setup: {test_setup}
   - Action: {test_action}
   - Verification: {test_verification}

2. **Bus Communication**
   - Setup: {bus_setup}
   - Action: {bus_action}
   - Verification: {bus_verification}

3. **Error Propagation**
   - Setup: {error_setup}
   - Action: {error_action}
   - Verification: {error_verification}

### Test Data
```json
{
  "valid_inputs": [
    {
      // Valid test case 1
    },
    {
      // Valid test case 2
    }
  ],
  "invalid_inputs": [
    {
      // Invalid test case 1
    },
    {
      // Invalid test case 2
    }
  ],
  "edge_cases": [
    {
      // Edge case 1
    },
    {
      // Edge case 2
    }
  ]
}
```

### Mock Dependencies
- **External Service**: {mock_description}
- **Database**: {mock_description}
- **File System**: {mock_description}

## Implementation Notes

### Key Design Decisions
1. {decision_1_and_rationale}
2. {decision_2_and_rationale}
3. {decision_3_and_rationale}

### Architectural Considerations
- **Concurrency**: {concurrency_approach}
- **State Management**: {state_management_approach}
- **Resource Management**: {resource_management_approach}

### Security Considerations
- **Input Validation**: {validation_approach}
- **Authentication**: {auth_requirements}
- **Authorization**: {authz_requirements}
- **Data Protection**: {data_protection_measures}

## Usage Examples

### Basic Usage
```{language}
// Example of basic cell usage
```

### Advanced Usage
```{language}
// Example of advanced cell usage
```

### Integration Example
```{language}
// Example of integrating with other cells
```

## Monitoring and Observability

### Metrics
- **Request Count**: Total number of requests processed
- **Response Time**: Average response time per request
- **Error Rate**: Percentage of requests resulting in errors
- **Resource Usage**: CPU and memory consumption

### Logging
- **Info Level**: Successful operations, performance metrics
- **Warn Level**: Recoverable errors, performance degradation
- **Error Level**: Unrecoverable errors, system failures
- **Debug Level**: Detailed execution flow, variable states

### Health Checks
- **Readiness**: {readiness_check_description}
- **Liveness**: {liveness_check_description}
- **Dependency Health**: {dependency_health_checks}

## Deployment

### Environment Variables
- `{ENV_VAR_1}`: {description}
- `{ENV_VAR_2}`: {description}

### Configuration
```{config_format}
{
  // Configuration structure
}
```

### Resource Requirements
- **CPU**: {cpu_requirements}
- **Memory**: {memory_requirements}
- **Storage**: {storage_requirements}
- **Network**: {network_requirements}

## Changelog

### Version {version}
- {change_1}
- {change_2}
- {change_3}

## References

- [CBS Architecture Documentation](../ai/master_build_specs.md)
- [Cell Development Guidelines](../ai/.agent-os/standards/best-practices.md)
- [Message Schema Definitions](../ai/docs/schemas/)
- [Error Code Reference](../ai/docs/error_codes.md)
