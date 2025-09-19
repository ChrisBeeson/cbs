# CBS Framework Metadata

This directory contains CBS framework metadata and configuration.

## Files

- `framework_version` - CBS framework version this project uses
- `config.yaml` - CBS-specific project configuration (future)

## Framework Integration

This project uses CBS Framework v0.1.0. The framework provides:
- Core CBS contracts and traits
- Message bus implementation  
- Cell orchestration
- Validation and tooling

## Upgrading Framework

To upgrade to a new CBS framework version:
1. Update the version in `framework_version`
2. Update `Cargo.toml` framework dependency
3. Run `cbs validate` to check compatibility
4. Update any breaking changes per migration guide

