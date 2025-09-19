# Feature Addition Workflow - Flutter Flow Web

## Overview

This document outlines the process for adding new features to the Flutter Flow Web application, emphasizing modular cell design and spec-first development.

## Step-by-Step Process

### 1. Feature Analysis & Cell Decomposition

**Goal**: Break the feature into modular, reusable cells

**Questions to Ask**:
- What single responsibilities can be identified?
- Which parts could be reused in other applications?
- How does this feature interact with existing cells?
- What bus messages will be needed?

**Example**: Adding a "Theme Switcher" feature
```
Potential Cells:
- theme_manager (logic) - Manages theme state
- theme_ui (ui) - Theme selection interface  
- theme_storage (storage) - Persists theme preferences
```

### 2. Update Tasks & Planning

**Actions**:
- Add feature tasks to `ai/tasks.md`
- Update `ai/history.md` with decision context
- Identify dependencies and integration points

**Template**:
```markdown
| TH001 | Add theme switcher feature | pending | dev | high | 2025-09-19 | 2025-09-19 |
| TH002 | Create theme_manager cell spec | pending | dev | high | 2025-09-19 | 2025-09-19 |
| TH003 | Implement theme_ui cell | pending | dev | medium | 2025-09-19 | 2025-09-19 |
```

### 3. Spec-First Development

**For Each New Cell**:

1. **Create/Update `ai/spec.md`**:
   ```markdown
   **id**: theme_manager
   **name**: ThemeManagerCell  
   **version**: 1.0.0
   **language**: dart
   **category**: logic
   **purpose**: Manages application theme state and transitions
   
   ## Interface
   - subscribe: `cbs.theme.get_current`, `cbs.theme.set_theme`
   - publish: `cbs.theme.changed`, `cbs.theme.current_response`
   - envelope: ThemeEnvelope
   ```

2. **Define Bus Contracts**:
   ```markdown
   ## Subjects
   - `cbs.theme.get_current` - Request current theme
   - `cbs.theme.set_theme` - Change theme
   - `cbs.theme.changed` - Theme change notification
   ```

3. **Plan Internal Modularity**:
   ```markdown
   ## Internal Structure
   - `lib/theme_manager_cell.dart` - Main cell implementation
   - `lib/models/theme_state.dart` - Theme data models
   - `lib/services/theme_service.dart` - Theme business logic
   - `lib/providers/theme_provider.dart` - Riverpod state management
   ```

### 4. Update Application Configuration

**Modify `birthmap.yaml`**:
```yaml
cells:
  - name: theme_manager
    path: cells/theme_manager
    dependencies: []
  - name: theme_ui
    path: cells/theme_ui
    dependencies: [theme_manager]
  # ... existing cells

flows:
  - name: theme_switch
    steps:
      - cell: theme_ui
        action: user_selection
      - cell: theme_manager
        action: apply_theme
```

### 5. Implementation

**Development Order**:
1. Create cell directory structure
2. Implement based on spec (internal modularity encouraged)
3. Write unit tests for cell logic
4. Write integration tests for bus communication
5. Update cell map: `python3 ai/scripts/generate_cell_map.py`

### 6. Integration & Testing

**Verification Steps**:
- Validate specs: `python3 ai/scripts/validate_spec.py`
- Test bus communication patterns
- Verify no direct cell-to-cell calls
- Check modular design within cells
- Update documentation

## Cell Modularity Opportunities

### When to Create New Cells

✅ **Create New Cell When**:
- Single, clear responsibility emerges
- Component could be reused elsewhere
- Different deployment/scaling needs
- Distinct error handling requirements
- Clear bus interface boundary

❌ **Keep in Same Cell When**:
- Tightly coupled internal logic
- Shared state that's hard to split
- Performance requires co-location
- Simple helper functions

### Internal Cell Organization

**Recommended Structure**:
```
cells/my_cell/
  ai/spec.md                    # Cell specification
  lib/
    my_cell.dart               # Main cell class
    models/                    # Data models
    services/                  # Business logic
    providers/                 # State management (Riverpod)
    widgets/                   # UI components (if ui cell)
    utils/                     # Helper functions
  test/
    my_cell_test.dart         # Unit tests
    integration_test.dart     # Bus integration tests
```

## Best Practices

### Spec-First Development
- Always update specs before coding
- Define bus contracts clearly
- Document internal modularity plans
- Consider reusability from the start

### Modular Design
- Single responsibility per cell
- Clear internal organization
- Reusable components when possible
- Clean separation of concerns

### Bus Communication
- Use typed envelopes
- Follow `cbs.<service>.<verb>` pattern
- Handle errors gracefully
- Log with correlation IDs

### Task Management
- Break features into cell-level tasks
- Update `tasks.md` regularly
- Document decisions in `history.md`
- Link tasks to specific cells/specs

## Example: Adding a New Feature

Let's say we want to add "User Preferences" functionality:

1. **Analysis**: 
   - `preference_manager` (logic) - Core preference logic
   - `preference_ui` (ui) - Settings interface
   - `preference_storage` (storage) - Persistence layer

2. **Tasks**:
   ```
   | UP001 | Create preference_manager spec | pending | dev | high | 2025-09-19 |
   | UP002 | Create preference_storage spec | pending | dev | high | 2025-09-19 |  
   | UP003 | Create preference_ui spec | pending | dev | medium | 2025-09-19 |
   ```

3. **Specs**: Define each cell's interface and internal structure

4. **Implementation**: Build modular, reusable cells following specs

5. **Integration**: Update birthmap, test bus communication

This workflow ensures modular, maintainable, and reusable cell architecture while maintaining CBS principles.
