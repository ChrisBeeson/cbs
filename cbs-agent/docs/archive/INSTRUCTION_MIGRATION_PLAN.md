# CBS Instructions Migration Plan

## 🎯 Goal: Intuitive, User-Focused Instructions

Transform confusing, redundant instruction files into clear, action-oriented workflows that match how users actually think.

## 📋 Migration Strategy

### **Phase 1: Create New Intuitive Structure** ✅ COMPLETED

**New Directory Structure**:
```
instructions/
├── app/           # Application-level operations
│   ├── app-create.md     ✅ CREATED
│   ├── app-refine.md     ✅ CREATED  
│   ├── app-breakdown.md  📝 TODO
│   └── app-deploy.md     📝 TODO
├── cell/          # Cell-level operations  
│   ├── cell-design.md    📝 TODO
│   ├── cell-refine.md    ✅ CREATED
│   ├── cell-build.md     📝 TODO
│   └── cell-debug.md     📝 TODO
├── feature/       # Feature management
│   ├── feature-add.md    ✅ CREATED
│   ├── feature-refine.md 📝 TODO
│   └── feature-remove.md 📝 TODO
├── system/        # System-level debugging
│   ├── cells-debug.md    📝 TODO
│   ├── messages-trace.md 📝 TODO
│   └── isolation-validate.md 📝 TODO
├── meta/          # Meta instructions (keep existing)
└── workflows/     # Workflow orchestration (keep existing)
```

### **Phase 2: Migrate Good Content** 📝 IN PROGRESS

**Content Migration Map**:
```
OLD FILE                    → NEW FILE(S)              STATUS
════════════════════════════════════════════════════════════
analyze-product.md          → app-create.md            ✅ MIGRATED
plan-product.md            → app-create.md            ✅ MIGRATED
create-spec.md             → cell-design.md           📝 TODO
execute-cell-spec.md       → cell-design.md           📝 TODO
create-cell.md             → cell-design.md           📝 TODO
create-tasks.md            → cell-build.md            📝 TODO
execute-tasks.md           → cell-build.md            📝 TODO
execute-task.md            → [DELETE - REDUNDANT]     📝 TODO
post-execution-tasks.md    → cell-build.md            📝 TODO
```

### **Phase 3: Remove Outdated Files** 📝 PENDING

**Files to Delete**:
```bash
# Redundant files
rm cbs-agent/instructions/core/execute-task.md          # Redundant with execute-tasks.md

# Confusing/outdated files  
rm cbs-agent/instructions/core/analyze-product.md       # Replaced by app-create.md
rm cbs-agent/instructions/core/plan-product.md         # Replaced by app-create.md
rm cbs-agent/instructions/core/create-spec.md          # Replaced by cell-design.md

# Files that will be replaced
rm cbs-agent/instructions/core/execute-cell-spec.md    # Content moved to cell-design.md
rm cbs-agent/instructions/core/create-cell.md          # Content moved to cell-design.md
rm cbs-agent/instructions/core/create-tasks.md         # Content moved to cell-build.md
rm cbs-agent/instructions/core/execute-tasks.md        # Content moved to cell-build.md
rm cbs-agent/instructions/core/post-execution-tasks.md # Content moved to cell-build.md
```

## 🎨 New CLI Command Mapping

### **Intuitive User Commands**:
```bash
# Application lifecycle
cbs app create <name>       → app-create.md
cbs app refine             → app-refine.md
cbs app breakdown          → app-breakdown.md
cbs app deploy             → app-deploy.md

# Cell development  
cbs cell design <name>     → cell-design.md
cbs cell refine <name>     → cell-refine.md
cbs cell build <name>      → cell-build.md
cbs cell debug <name>      → cell-debug.md

# Feature management
cbs feature add <name>     → feature-add.md
cbs feature refine <name>  → feature-refine.md
cbs feature remove <name>  → feature-remove.md

# System debugging
cbs cells debug            → cells-debug.md
cbs messages trace <cell>  → messages-trace.md
cbs isolation validate     → isolation-validate.md
```

## 📊 Content Migration Details

### **app-create.md** ✅ COMPLETED
- **Sources**: `analyze-product.md` + `plan-product.md`
- **Enhanced**: Added workflow integration, CBS focus
- **New Features**: Iterative refinement, proper validation

### **app-refine.md** ✅ COMPLETED  
- **Sources**: New creation based on user needs
- **Purpose**: Iterate on application specifications
- **Features**: Unlimited iterations, impact analysis, rollback

### **cell-refine.md** ✅ COMPLETED
- **Sources**: New creation based on user needs
- **Purpose**: Iterate on individual cell specifications
- **Features**: Cell isolation validation, cascade updates

### **feature-add.md** ✅ COMPLETED
- **Sources**: New creation based on user needs
- **Purpose**: Add features to existing applications
- **Features**: Cell impact analysis, message flow design

## 🚀 Revolutionary Improvements

### **1. User-Centric Naming**
- **Before**: "execute-cell-spec.md" (confusing)
- **After**: "cell-design.md" (clear purpose)

### **2. Workflow Integration**
- **Before**: Isolated instructions with no state tracking
- **After**: Full integration with workflow state and iterations

### **3. Unlimited Iterations**
- **Before**: Single-shot instructions
- **After**: Unlimited refinement cycles with rollback

### **4. Impact Analysis**
- **Before**: No consideration of changes on other components
- **After**: Full impact analysis and cascade effect management

### **5. Debugging Support**
- **Before**: No debugging workflows
- **After**: Comprehensive debugging and troubleshooting instructions

## 📈 Expected Benefits

### **Developer Experience**:
- ✅ **Intuitive**: Commands match user mental model
- ✅ **Complete**: Cover all common development scenarios
- ✅ **Forgiving**: Easy rollback and iteration
- ✅ **Guided**: Clear next steps and suggestions

### **CBS Compliance**:
- ✅ **Cell Isolation**: Maintained throughout all workflows
- ✅ **Bus Communication**: Enforced in all instructions
- ✅ **Message Contracts**: Proper design and validation
- ✅ **Standards**: Consistent application of CBS principles

### **Workflow Quality**:
- ✅ **State Tracking**: Complete workflow state management
- ✅ **Iteration Support**: Unlimited refinement cycles
- ✅ **Rollback Safety**: Safe experimentation and changes
- ✅ **Integration**: Seamless integration between all workflows

## 🎯 Next Actions

1. **Complete Migration**: Finish creating remaining instruction files
2. **Update CLI**: Update CBS CLI to use new instruction names
3. **Test Workflows**: Validate new instructions with real development
4. **Remove Old Files**: Clean up outdated instruction files
5. **Update Documentation**: Update all references to new instruction names

This migration transforms the CBS agent from a confusing collection of files into an intuitive, powerful development system that matches how users actually think and work.
