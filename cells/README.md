# CBS Cells

## Overview

Cells are the fundamental units of computation in the Cell Body System (CBS). Each cell performs a single, well-defined task and communicates with other cells through the Body Bus using typed envelopes.

## Directory Structure

**Note**: This directory contains legacy example cells. The new CBS architecture uses self-contained applications under `applications/` directory.

### Current Structure (Legacy)
```
cells/
├── README.md                    # This file
├── SPEC_TEMPLATE.md            # Template for cell specifications
├── examples/                   # Example cells (moved to applications/)
│   ├── greeter_rs/            # Simple greeting cell
│   ├── io_print_greeting_rs/  # Output cell for printing
│   ├── io_prompt_name_rs/     # Input cell for name prompting
│   └── logic_greet_rs/        # Pure logic greeting cell
├── python/                    # Python cell framework
└── flutter/                   # Dart/Flutter cell framework
```

### New Structure (Recommended)
```
examples/applications/         # Self-contained applications
├── cli_greeter/               # CLI greeter application
│   ├── app.yaml              # Application configuration
│   └── cells/                # Application-specific cells
└── flutter_flow_web/         # Flutter web application
    ├── app.yaml              # Application configuration
    └── cells/                # Application-specific cells

framework/shared_cells/        # Reusable cells across applications
├── rust/                     # Shared Rust cells
└── dart/                     # Shared Dart cells
```

## Cell Categories

Cells are organized into logical categories based on their primary function:

### IO Cells (`io/`)
Handle input/output operations such as:
- Reading from stdin/stdout
- File system operations
- Network I/O
- User interface interactions

### Logic Cells (`logic/`)
Perform pure business logic transformations:
- Data processing
- Calculations
- Formatting
- Validation

### Storage Cells (`storage/`)
Manage data persistence and retrieval:
- Database operations
- Caching
- File storage
- State management

### Integration Cells (`integration/`)
Handle external service integrations:
- API calls
- Message queue operations
- Third-party service connections
- Protocol translations

## Application Development Process

### Creating New Applications

For self-contained applications, create them in the `examples/applications/` directory:

```bash
# Create new application
cargo run -p body -- --new-app my_app --template web

# This creates:
# examples/applications/my_app/
# ├── app.yaml              # Application configuration
# ├── README.md             # Application documentation
# └── cells/                # Application-specific cells
```

### Creating Individual Cells

To create or modify a cell specification within an application, use the Agent OS command:

```bash
@execute-cell-spec.md
```

This command will guide you through:
1. Cell type identification
2. Specification creation
3. Directory structure setup
4. Interface definition
5. Test specification
6. Implementation template creation
7. Documentation generation
8. Validation checklist

## Cell Requirements

Every cell must:

1. **Implement the Cell trait** with:
   - `id()` - unique identifier
   - `subjects()` - list of subscribed subjects
   - `register()` - bus registration logic

2. **Follow CBS patterns**:
   - Use standard envelope format
   - Implement proper error handling
   - Follow subject naming conventions
   - Use appropriate queue groups

3. **Include comprehensive specifications**:
   - Complete SPEC.md file
   - Interface documentation
   - Test scenarios
   - Usage examples

4. **Provide complete testing**:
   - Unit tests for core functionality
   - Integration tests for bus communication
   - Edge case coverage
   - Mock dependencies where needed

## Language Support

### Rust (Current)
- Full support with body_core integration
- Examples available in `examples/` directory
- Complete trait implementations
- Comprehensive testing framework

### Python (Planned)
- Framework structure in place
- SDK development in progress
- Integration with CBS bus planned
- Polyglot messaging support

### Dart/Flutter (Planned)
- Framework structure in place
- Mobile/web UI cell support planned
- Isolate-based execution model
- Cross-platform compatibility

## Getting Started

### For New Applications (Recommended)

1. **Create application directory**: Use `--new-app` command or manually create under `examples/applications/`
2. **Design application structure**: Define cells, configuration, and flows in `app.yaml`
3. **Create application cells**: Use `@execute-cell-spec.md` for each cell
4. **Write tests first**: Follow TDD approach for all cells
5. **Implement cells**: Follow CBS patterns and specifications
6. **Run application**: `cargo run -p body -- --app my_app`

### For Individual Cells (Legacy)

1. **Choose a cell type** based on functionality
2. **Use the specification command**: `@execute-cell-spec.md`
3. **Follow the generated structure** for implementation
4. **Write tests first** using TDD approach
5. **Implement the cell** following CBS patterns
6. **Validate against specification** before deployment

## Best Practices

- **Single Responsibility**: Each cell should do one thing well
- **Stateless Design**: Prefer stateless cells for better scalability
- **Error Handling**: Always handle errors gracefully
- **Testing**: Write comprehensive tests before implementation
- **Documentation**: Keep specifications up to date
- **Performance**: Design for high throughput and low latency
- **Monitoring**: Include proper logging and metrics

## Examples

### Legacy Examples (examples/ directory)
- `greeter_rs/` - Simple greeting logic
- `io_prompt_name_rs/` - Input handling
- `io_print_greeting_rs/` - Output handling
- `logic_greet_rs/` - Pure logic transformation

### Modern Applications (examples/applications/ directory)
- `examples/applications/cli_greeter/` - Complete CLI greeting application
- `examples/applications/flutter_flow_web/` - Flutter web application

Each example includes:
- Complete specification (SPEC.md)
- Implementation (src/lib.rs or lib/)
- Comprehensive tests
- Usage documentation
- Application configuration (app.yaml for applications)

## Integration with CBS

Cells integrate with the CBS system through:
- **Body Bus**: Message routing and communication
- **Envelopes**: Typed message format
- **Subjects**: NATS-style topic routing
- **Queue Groups**: Load balancing and scaling
- **Error Handling**: Standardized error responses

For more information, see:
- [CBS Master Specification](../ai/master_build_specs.md)
- [Architecture Documentation](../ai/docs/)
- [Best Practices](../ai/.agent-os/standards/best-practices.md)
