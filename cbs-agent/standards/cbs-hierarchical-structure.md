# CBS Hierarchical Cell Structure Standard

## 🎯 Problem Statement

As CBS applications grow complex, flat `cells/` directories become unmanageable. We need **hierarchical organization** that scales while maintaining CBS principles.

## 🏗️ Proposed Hierarchical Structure

### **Level 1: Domain/Feature Organization**
```
applications/my_complex_app/cells/
├── authentication/              # Auth domain
│   ├── auth_ui/                # Login/signup UI
│   ├── auth_logic/             # Auth business logic
│   ├── auth_storage/           # User data persistence
│   └── oauth_integration/      # External OAuth providers
├── messaging/                  # Messaging domain
│   ├── message_ui/             # Chat interface
│   ├── message_logic/          # Message processing
│   ├── message_storage/        # Message persistence
│   ├── notification_service/   # Push notifications
│   └── realtime_sync/          # WebSocket/real-time
├── user_management/            # User domain
│   ├── profile_ui/             # User profile interface
│   ├── profile_logic/          # Profile business logic
│   ├── user_storage/           # User data management
│   └── avatar_service/         # Avatar/image handling
├── analytics/                  # Analytics domain
│   ├── event_collector/        # Event collection
│   ├── analytics_processor/    # Data processing
│   └── reporting_service/      # Report generation
└── shared/                     # Shared utilities
    ├── error_handler/          # Global error handling
    ├── logger/                 # Logging infrastructure
    └── validation/             # Input validation
```

### **Level 2: Cell Category Organization (Alternative)**
```
applications/my_complex_app/cells/
├── ui/                         # All UI cells
│   ├── authentication/
│   │   ├── login_ui/
│   │   └── signup_ui/
│   ├── messaging/
│   │   ├── chat_ui/
│   │   └── message_list_ui/
│   └── user_management/
│       └── profile_ui/
├── logic/                      # All logic cells
│   ├── authentication/
│   │   ├── auth_logic/
│   │   └── session_manager/
│   ├── messaging/
│   │   ├── message_processor/
│   │   └── chat_logic/
│   └── user_management/
│       └── profile_logic/
├── integration/                # All integration cells
│   ├── oauth_providers/
│   ├── notification_services/
│   └── external_apis/
├── storage/                    # All storage cells
│   ├── user_storage/
│   ├── message_storage/
│   └── analytics_storage/
└── io/                         # All IO cells
    ├── file_handler/
    ├── export_service/
    └── import_service/
```

### **Level 3: Hybrid Organization (Recommended)**
```
applications/my_complex_app/cells/
├── core/                       # Core application cells
│   ├── ui/
│   │   ├── main_shell/         # App shell and navigation
│   │   └── error_display/      # Global error UI
│   ├── logic/
│   │   ├── app_controller/     # Main app logic
│   │   └── state_manager/      # Global state
│   └── infrastructure/
│       ├── logger/             # Logging
│       └── config_manager/     # Configuration
├── features/                   # Feature-specific cells
│   ├── authentication/
│   │   ├── ui/
│   │   │   ├── login_form/
│   │   │   └── signup_wizard/
│   │   ├── logic/
│   │   │   ├── auth_processor/
│   │   │   └── session_manager/
│   │   ├── storage/
│   │   │   └── user_store/
│   │   └── integration/
│   │       ├── oauth_google/
│   │       └── oauth_github/
│   ├── messaging/
│   │   ├── ui/
│   │   │   ├── chat_interface/
│   │   │   ├── message_composer/
│   │   │   └── conversation_list/
│   │   ├── logic/
│   │   │   ├── message_processor/
│   │   │   ├── encryption_service/
│   │   │   └── search_engine/
│   │   ├── storage/
│   │   │   ├── message_store/
│   │   │   └── conversation_store/
│   │   └── integration/
│   │       ├── push_notifications/
│   │       ├── file_upload/
│   │       └── realtime_sync/
│   └── user_management/
│       ├── ui/
│       │   ├── profile_editor/
│       │   └── settings_panel/
│       ├── logic/
│       │   ├── profile_processor/
│       │   └── preferences_manager/
│       └── storage/
│           └── profile_store/
└── shared/                     # Shared across features
    ├── ui/
    │   ├── design_system/      # UI components
    │   └── theme_manager/      # Theming
    ├── logic/
    │   ├── validation/         # Input validation
    │   └── utilities/          # Common utilities
    └── integration/
        ├── api_client/         # HTTP client
        └── websocket_client/   # WebSocket client
```

## 📋 Hierarchical Structure Rules

### **Directory Naming Conventions**
- **Domain/Feature**: `snake_case` (e.g., `user_management`, `real_time_messaging`)
- **Category**: `snake_case` (e.g., `ui`, `logic`, `storage`, `integration`, `io`)
- **Cell**: `snake_case` (e.g., `auth_processor`, `message_ui`, `file_uploader`)

### **Cell Addressing in Hierarchy**
```bash
# Full cell path for identification
applications/my_app/cells/features/messaging/ui/chat_interface/

# Cell ID remains flat for bus communication
CELL_ID: "chat_interface"  # NOT "features.messaging.ui.chat_interface"

# Bus subjects remain flat
SUBJECT: "cbs.chat_interface.send_message"  # Clear and simple
```

### **Spec File Location**
```bash
# Folder hierarchy (kebab-case)

applications/<app>/cells/<domain>/<category>/<cell-name>

- domain: core | features | shared
- category: ui | logic | storage | integration | io

Examples:

applications/my_app/cells/features/auth/ui/login-form/.cbs-spec/spec.md
applications/my_app/cells/core/logic/app-controller/.cbs-spec/spec.md
applications/my_app/cells/shared/integration/payment-gateway/.cbs-spec/spec.md

# Cell implementation
applications/my_app/cells/features/messaging/ui/chat_interface/lib/chat_interface_cell.dart
```

## 🔧 Implementation in CBS Tools

### **Updated CLI Commands**
```bash
# Hierarchical cell creation
cbs cell create features/messaging/ui/chat_interface --language dart

# Navigate hierarchy
cbs cells list features/messaging          # List cells in messaging feature
cbs cells list --category ui               # List all UI cells
cbs cells list features/messaging/ui       # List UI cells in messaging

# Work with hierarchical cells
cbs cell build features/messaging/ui/chat_interface
cbs cell refine features/messaging/logic/message_processor
cbs feature add features/analytics         # Add entire analytics feature domain
```

### **Workflow State Integration**
```yaml
# Enhanced workflow state for hierarchy
phases:
  cell_specs:
    cells:
      core/ui/main_shell: "spec_complete"
      features/auth/ui/login_form: "spec_pending"
      features/auth/logic/auth_processor: "spec_complete"
      features/messaging/ui/chat_interface: "implementation_complete"
    domains:
      - core: ["main_shell", "app_controller", "logger"]
      - authentication: ["login_form", "auth_processor", "user_store"]
      - messaging: ["chat_interface", "message_processor", "message_store"]
```

### **Cell Discovery and Validation**
```bash
# Enhanced CBS validation for hierarchical structure
cbs validate --specs                       # Validates all cells in hierarchy
cbs validate --domain features/messaging   # Validates specific domain
cbs validate --category ui                 # Validates all UI cells
cbs isolation validate --domain features/auth  # Check domain isolation
```

## 📊 Benefits of Hierarchical Structure

### **🎯 Organization Benefits**
- **Logical Grouping**: Related cells grouped by domain/feature
- **Scalability**: Structure scales to hundreds of cells
- **Navigation**: Easy to find and work with related cells
- **Maintenance**: Clear ownership and responsibility boundaries

### **🧬 CBS Compliance Benefits**
- **Domain Isolation**: Features can be developed independently
- **Message Contracts**: Clear boundaries between domains
- **Reusability**: Shared cells clearly identified and accessible
- **Testing**: Domain-level integration testing possible

### **👥 Team Benefits**
- **Ownership**: Teams can own specific domains/features
- **Parallel Development**: Multiple teams work on different domains
- **Code Review**: Focused reviews within domain boundaries
- **Deployment**: Domain-specific deployment strategies

## 🔄 Migration Strategy

### **Phase 1: Support Both Structures**
```bash
# Backward compatibility - both work
applications/my_app/cells/simple_cell/          # Flat structure (existing)
applications/my_app/cells/features/auth/ui/login_form/  # Hierarchical (new)
```

### **Phase 2: Enhanced Tools**
```bash
# Update CBS tools to handle both
cbs cell create auth_ui                         # Creates in flat structure
cbs cell create features/auth/ui/login_form     # Creates in hierarchy
cbs cells migrate --to-hierarchy                # Migrate existing flat to hierarchy
```

### **Phase 3: Best Practices**
```bash
# Recommend hierarchy for complex apps
cbs app create my_complex_app --structure hierarchical
cbs app create my_simple_app --structure flat
```

## 🎨 Advanced Hierarchical Features

### **Domain-Level Operations**
```bash
# Work with entire domains
cbs domain create authentication            # Create auth domain structure
cbs domain test features/messaging          # Test entire messaging domain
cbs domain deploy features/analytics        # Deploy analytics domain
```

### **Cross-Domain Dependencies**
```markdown
## Cross-Domain Message Contracts

### Authentication → Messaging
- `cbs.auth_processor.user_authenticated` → `cbs.message_processor.user_ready`
- Payload: `{user_id: string, permissions: string[]}`

### Messaging → User Management  
- `cbs.message_processor.user_mentioned` → `cbs.profile_processor.get_profile`
- Payload: `{mentioned_user_id: string, context: string}`
```

### **Hierarchical Cell Maps**
```markdown
# Enhanced cell map with hierarchy
## CBS Cell Map - my_complex_app

### Core Domain
| Cell | Path | Category | Subscribes | Publishes |
|------|------|----------|------------|-----------|
| main_shell | core/ui/main_shell | ui | cbs.shell.render | cbs.navigation.request |

### Authentication Domain  
| Cell | Path | Category | Subscribes | Publishes |
|------|------|----------|------------|-----------|
| login_form | features/auth/ui/login_form | ui | cbs.login.render | cbs.auth.attempt |
| auth_processor | features/auth/logic/auth_processor | logic | cbs.auth.attempt | cbs.auth.result |
```

## 🚀 Implementation Plan

Let me update the CBS tools to support this hierarchical structure while maintaining backward compatibility.

Would you like me to:
1. **Update the cell creation tools** to support hierarchical paths?
2. **Enhance the workflow system** to track hierarchical cell organization?
3. **Create migration tools** to move existing flat structures to hierarchical?
4. **Update validation tools** to work with hierarchical cell discovery?

This hierarchical approach will handle the complexity you're anticipating while maintaining all CBS principles! 🧬
