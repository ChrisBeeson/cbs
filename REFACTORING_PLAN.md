# CBS Framework Refactoring Plan

## 🎯 Goal: Transform CBS into a Clean Base Framework

Currently CBS mixes framework code with example applications. This plan separates concerns to create a reusable framework template.

## 🏗️ Proposed Structure

### Framework Repository (this repo)
```
cbs-framework/
├── framework/              # 🚀 Core CBS Framework
│   ├── body_core/         # Contracts & traits  
│   ├── body_bus/          # Message bus
│   ├── body/              # Main orchestrator
│   └── shared_cells/      # Reusable cells
├── template/              # 📋 Clean Project Template
│   ├── Cargo.toml         # Template workspace
│   ├── app.yaml           # App config template
│   ├── applications/      # Empty directory
│   └── .cbs/              # Framework metadata
├── examples/              # 📚 Example Projects
│   ├── cli_greeter/       # Moved from applications/
│   └── flutter_flow_web/  # Moved from applications/
├── tools/                 # 🛠️ Framework Tools
│   ├── cbs-new           # Project scaffolding
│   ├── cbs-cell          # Cell creation
│   └── cbs-validate      # Validation
└── docs/                 # 📖 Framework Docs
```

### User Project (separate repo)
```
my-cbs-project/
├── Cargo.toml            # Project workspace
├── app.yaml              # Project config
├── applications/         # User applications
└── .cbs/                 # Framework reference
```

## 🔄 Migration Steps

### Step 1: Reorganize Current Structure
- [ ] Move `applications/` → `examples/`
- [ ] Create `framework/` directory
- [ ] Move core components to `framework/`
- [ ] Create clean `template/` directory

### Step 2: Create Framework Tools
- [ ] `cbs-new` - scaffolds new projects from template
- [ ] `cbs-cell` - creates new cells with proper structure  
- [ ] `cbs-validate` - validates CBS compliance

### Step 3: Clean Documentation
- [ ] Framework README (how to use CBS as base)
- [ ] Project template README (for user projects)
- [ ] Migration guide for existing projects

### Step 4: Package for Distribution
- [ ] Publish framework as Rust crate
- [ ] Create `cargo generate` template
- [ ] Publish Dart SDK to pub.dev

## 🎯 Usage After Refactoring

### Creating New CBS Project
```bash
# Option 1: Using cargo generate
cargo generate --git https://github.com/user/cbs-framework

# Option 2: Using CBS CLI (future)
cargo install cbs-framework
cbs new my-project
```

### Project Structure
```
my-project/
├── Cargo.toml              # References cbs-framework
├── app.yaml                # Project config
├── applications/
│   └── my_app/
│       ├── app.yaml
│       └── cells/
│           └── my_cell/
│               ├── ai/spec.md
│               ├── lib/
│               └── test/
└── .cbs/
    └── framework_version   # CBS version tracking
```

## 🚀 Benefits

1. **Clean Separation**: Framework vs application code clearly separated
2. **Easy Templating**: Start new projects without example clutter
3. **Versioned Framework**: Lock to specific CBS framework versions
4. **Reusable**: Same framework for multiple projects
5. **Maintainable**: Framework updates don't affect user applications
6. **Distributable**: Can package and share framework easily

## 📋 Implementation Priority

1. **High Priority**: Reorganize structure, create template
2. **Medium Priority**: Create scaffolding tools
3. **Low Priority**: Package management and distribution

## 🔧 Technical Considerations

- **Backward Compatibility**: Ensure existing applications still work
- **Framework Versioning**: Semantic versioning for framework releases
- **Dependency Management**: Clean separation of framework vs app dependencies
- **Documentation**: Clear docs for both framework developers and users


