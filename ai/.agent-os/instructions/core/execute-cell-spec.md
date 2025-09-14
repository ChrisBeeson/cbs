---
description: Rules to create or edit cell specifications in the CBS system
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Cell Specification Execution Rules

## Overview

Create or edit specifications for CBS cells, ensuring they are properly structured, documented, and testable. Each cell must have a clear specification that defines its purpose, interface, and behavior.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="cell_type_identification">

### Step 1: Cell Type Identification

Determine the type of cell being specified and its appropriate location in the cells directory structure.

<cell_categories>
  <io_cells>
    - Handle input/output operations
    - Examples: stdin/stdout, file I/O, network I/O
    - Location: cells/{language}/io/
  </io_cells>
  <logic_cells>
    - Pure business logic transformations
    - Examples: data processing, calculations, formatting
    - Location: cells/{language}/logic/
  </logic_cells>
  <storage_cells>
    - Data persistence and retrieval
    - Examples: database operations, caching
    - Location: cells/{language}/storage/
  </storage_cells>
  <integration_cells>
    - External service integrations
    - Examples: API calls, message queues
    - Location: cells/{language}/integration/
  </integration_cells>
</cell_categories>

<instructions>
  ACTION: Identify the cell's primary function
  CATEGORIZE: Place in appropriate organ namespace
  LOCATION: Determine correct directory structure
  LANGUAGE: Choose implementation language (Rust/Python/Dart)
</instructions>

</step>

<step number="2" name="cell_spec_creation">

### Step 2: Cell Specification Creation

Create a comprehensive specification document for the cell that includes all required elements.

<spec_structure>
  <metadata>
    - Cell ID and name
    - Version and language
    - Category and purpose
    - Dependencies
  </metadata>
  <interface>
    - Subjects subscribed to
    - Message schemas (input/output)
    - Error handling
    - Queue groups
  </interface>
  <behavior>
    - Functional requirements
    - Edge cases
    - Performance expectations
    - Error conditions
  </behavior>
  <testing>
    - Unit test scenarios
    - Integration test cases
    - Mock dependencies
    - Test data
  </testing>
</spec_structure>

<instructions>
  ACTION: Create SPEC.md file in cell directory
  INCLUDE: All required specification elements
  FORMAT: Use structured markdown with clear sections
  VALIDATE: Ensure completeness and clarity
</instructions>

</step>

<step number="3" name="directory_structure_setup">

### Step 3: Directory Structure Setup

Create the proper directory structure to support the cell specification and implementation.

<cell_directory_structure>
  <rust_cell>
    cells/examples/{cell_name}_rs/
    ├── SPEC.md                 # Cell specification
    ├── Cargo.toml             # Rust package config
    ├── src/
    │   └── lib.rs             # Cell implementation
    ├── tests/
    │   ├── unit_tests.rs      # Unit tests
    │   └── integration_tests.rs # Integration tests
    └── README.md              # Quick setup guide
  </rust_cell>
  <python_cell>
    cells/python/{category}/{cell_name}/
    ├── SPEC.md                # Cell specification
    ├── pyproject.toml         # Python package config
    ├── src/
    │   └── {cell_name}.py     # Cell implementation
    ├── tests/
    │   ├── test_unit.py       # Unit tests
    │   └── test_integration.py # Integration tests
    └── README.md              # Quick setup guide
  </python_cell>
  <dart_cell>
    cells/flutter/{category}/{cell_name}/
    ├── SPEC.md                # Cell specification
    ├── pubspec.yaml           # Dart package config
    ├── lib/
    │   └── {cell_name}.dart   # Cell implementation
    ├── test/
    │   ├── unit_test.dart     # Unit tests
    │   └── integration_test.dart # Integration tests
    └── README.md              # Quick setup guide
  </dart_cell>
</cell_directory_structure>

<instructions>
  ACTION: Create directory structure for cell
  ENSURE: All required files and folders exist
  TEMPLATE: Use appropriate templates for each language
  ORGANIZE: Follow CBS organizational patterns
</instructions>

</step>

<step number="4" name="interface_definition">

### Step 4: Interface Definition

Define the cell's interface including subjects, message schemas, and error handling.

<interface_elements>
  <subjects>
    - Primary subject: cbs.{service}.{verb}
    - Queue group: {service}
    - Subject patterns for different operations
  </subjects>
  <message_schemas>
    - Input envelope schema
    - Output envelope schema
    - Error response schema
    - Payload validation rules
  </message_schemas>
  <error_handling>
    - Expected error conditions
    - Error codes and messages
    - Recovery strategies
    - Timeout handling
  </error_handling>
</interface_elements>

<instructions>
  ACTION: Define all message interfaces
  SPECIFY: Input/output schemas with examples
  DOCUMENT: Error conditions and codes
  VALIDATE: Interface consistency with CBS patterns
</instructions>

</step>

<step number="5" name="test_specification">

### Step 5: Test Specification

Define comprehensive test scenarios for the cell including unit tests, integration tests, and edge cases.

<test_categories>
  <unit_tests>
    - Pure function testing
    - Input validation
    - Output formatting
    - Error condition handling
  </unit_tests>
  <integration_tests>
    - Bus communication
    - End-to-end message flow
    - Timeout scenarios
    - Error propagation
  </integration_tests>
  <edge_cases>
    - Malformed input
    - Network failures
    - Resource exhaustion
    - Concurrent requests
  </edge_cases>
</test_categories>

<test_data_requirements>
  <valid_inputs>
    - Happy path scenarios
    - Boundary conditions
    - Multiple data formats
  </valid_inputs>
  <invalid_inputs>
    - Malformed payloads
    - Missing required fields
    - Type mismatches
  </invalid_inputs>
  <mock_dependencies>
    - External service responses
    - Database states
    - File system conditions
  </mock_dependencies>
</test_data_requirements>

<instructions>
  ACTION: Define all test scenarios in specification
  INCLUDE: Test data and expected outcomes
  SPECIFY: Mock requirements for dependencies
  ENSURE: Complete test coverage planning
</instructions>

</step>

<step number="6" name="implementation_template">

### Step 6: Implementation Template Creation

Create implementation templates that follow CBS patterns and best practices.

<template_elements>
  <cell_trait_implementation>
    - id() method returning unique identifier
    - subjects() method returning subscription list
    - register() method for bus registration
  </cell_trait_implementation>
  <message_handlers>
    - Handler functions for each subject
    - Envelope processing logic
    - Response generation
    - Error handling
  </message_handlers>
  <logging_integration>
    - Structured logging with context
    - Performance metrics
    - Error tracking
    - Debug information
  </logging_integration>
</template_elements>

<instructions>
  ACTION: Create implementation template files
  INCLUDE: Required trait implementations
  FOLLOW: CBS coding standards and patterns
  PREPARE: For TDD implementation workflow
</instructions>

</step>

<step number="7" name="documentation_generation">

### Step 7: Documentation Generation

Generate comprehensive documentation for the cell including README, API docs, and usage examples.

<documentation_components>
  <readme_content>
    - Cell purpose and functionality
    - Installation and setup instructions
    - Usage examples
    - Testing instructions
  </readme_content>
  <api_documentation>
    - Message interface documentation
    - Schema definitions
    - Error codes reference
    - Integration examples
  </api_documentation>
  <usage_examples>
    - Code snippets showing usage
    - Complete workflow examples
    - Integration patterns
    - Troubleshooting guide
  </usage_examples>
</documentation_components>

<instructions>
  ACTION: Generate all documentation files
  ENSURE: Clear and comprehensive coverage
  INCLUDE: Practical examples and guides
  MAINTAIN: Consistency with CBS documentation standards
</instructions>

</step>

<step number="8" name="validation_checklist">

### Step 8: Validation Checklist

Validate that the cell specification meets all CBS requirements and standards.

<validation_criteria>
  <specification_completeness>
    ✓ Cell purpose clearly defined
    ✓ Interface fully specified
    ✓ Test scenarios comprehensive
    ✓ Error handling documented
  </specification_completeness>
  <cbs_compliance>
    ✓ Follows CBS architectural patterns
    ✓ Uses standard envelope format
    ✓ Implements required traits
    ✓ Proper subject naming
  </cbs_compliance>
  <implementation_readiness>
    ✓ Directory structure complete
    ✓ Templates ready for implementation
    ✓ Dependencies specified
    ✓ Test framework configured
  </implementation_readiness>
</validation_criteria>

<instructions>
  ACTION: Review specification against checklist
  VERIFY: All requirements met
  CORRECT: Any deficiencies found
  CONFIRM: Ready for implementation phase
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
