use body_core::{AppConfig, AppLoader, CellConfig};
use std::fs;
use tempfile::TempDir;

#[cfg(test)]
mod app_loading_integration_tests {
    use super::*;

    fn create_test_applications_structure() -> (TempDir, String) {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        // Create flutter_flow_web app
        let flutter_app_dir = apps_dir.join("flutter_flow_web");
        fs::create_dir_all(&flutter_app_dir).unwrap();
        fs::create_dir_all(flutter_app_dir.join("cells/flow_ui")).unwrap();
        fs::create_dir_all(flutter_app_dir.join("web")).unwrap();
        
        let flutter_config = AppConfig {
            name: "flutter_flow_web".to_string(),
            version: "1.0.0".to_string(),
            description: "Flutter Flow Web Application".to_string(),
            cells: vec![CellConfig {
                name: "flow_ui".to_string(),
                path: "cells/flow_ui".to_string(),
                dependencies: vec![],
            }],
            shared_cells: vec!["cbs_sdk".to_string()],
        };
        
        let config_yaml = serde_yaml::to_string(&flutter_config).unwrap();
        fs::write(flutter_app_dir.join("app.yaml"), config_yaml).unwrap();
        
        // Create cli_greeter app
        let cli_app_dir = apps_dir.join("cli_greeter");
        fs::create_dir_all(&cli_app_dir).unwrap();
        fs::create_dir_all(cli_app_dir.join("cells/greeter_rs")).unwrap();
        fs::create_dir_all(cli_app_dir.join("cells/io_print_greeting_rs")).unwrap();
        
        let cli_config = AppConfig {
            name: "cli_greeter".to_string(),
            version: "1.0.0".to_string(),
            description: "CLI Greeter Application".to_string(),
            cells: vec![
                CellConfig {
                    name: "greeter_rs".to_string(),
                    path: "cells/greeter_rs".to_string(),
                    dependencies: vec![],
                },
                CellConfig {
                    name: "io_print_greeting_rs".to_string(),
                    path: "cells/io_print_greeting_rs".to_string(),
                    dependencies: vec![],
                },
            ],
            shared_cells: vec![],
        };
        
        let config_yaml = serde_yaml::to_string(&cli_config).unwrap();
        fs::write(cli_app_dir.join("app.yaml"), config_yaml).unwrap();
        
        (temp_dir, apps_dir.to_string_lossy().to_string())
    }

    #[test]
    fn test_app_loader_discovers_multiple_applications() {
        let (_temp_dir, apps_dir) = create_test_applications_structure();
        let loader = AppLoader::new(&apps_dir);
        
        let apps = loader.discover_applications().unwrap();
        assert_eq!(apps.len(), 2);
        assert!(apps.contains(&"flutter_flow_web".to_string()));
        assert!(apps.contains(&"cli_greeter".to_string()));
    }

    #[test]
    fn test_load_flutter_flow_web_application() {
        let (_temp_dir, apps_dir) = create_test_applications_structure();
        let loader = AppLoader::new(&apps_dir);
        
        let config = loader.load_application("flutter_flow_web").unwrap();
        assert_eq!(config.name, "flutter_flow_web");
        assert_eq!(config.cells.len(), 1);
        assert_eq!(config.cells[0].name, "flow_ui");
        assert_eq!(config.shared_cells, vec!["cbs_sdk"]);
    }

    #[test]
    fn test_load_cli_greeter_application() {
        let (_temp_dir, apps_dir) = create_test_applications_structure();
        let loader = AppLoader::new(&apps_dir);
        
        let config = loader.load_application("cli_greeter").unwrap();
        assert_eq!(config.name, "cli_greeter");
        assert_eq!(config.cells.len(), 2);
        assert!(config.cells.iter().any(|c| c.name == "greeter_rs"));
        assert!(config.cells.iter().any(|c| c.name == "io_print_greeting_rs"));
    }

    #[test]
    fn test_application_switching_via_parameter() {
        let (_temp_dir, apps_dir) = create_test_applications_structure();
        let loader = AppLoader::new(&apps_dir);
        
        // Test switching to flutter_flow_web
        let flutter_config = loader.load_application("flutter_flow_web").unwrap();
        assert_eq!(flutter_config.name, "flutter_flow_web");
        
        // Test switching to cli_greeter
        let cli_config = loader.load_application("cli_greeter").unwrap();
        assert_eq!(cli_config.name, "cli_greeter");
        
        // Verify they are different configurations
        assert_ne!(flutter_config.name, cli_config.name);
        assert_ne!(flutter_config.cells.len(), cli_config.cells.len());
    }

    #[test]
    fn test_application_directory_structure_validation() {
        let (_temp_dir, apps_dir) = create_test_applications_structure();
        let loader = AppLoader::new(&apps_dir);
        
        let config = loader.load_application("flutter_flow_web").unwrap();
        
        // Verify cell paths exist
        let app_path = loader.get_app_path("flutter_flow_web");
        for cell in &config.cells {
            let cell_path = app_path.join(&cell.path);
            assert!(cell_path.exists(), "Cell path should exist: {:?}", cell_path);
        }
        
        // Verify web directory exists for flutter app
        let web_path = app_path.join("web");
        assert!(web_path.exists(), "Web directory should exist for flutter app");
    }

    #[test]
    fn test_invalid_application_name() {
        let (_temp_dir, apps_dir) = create_test_applications_structure();
        let loader = AppLoader::new(&apps_dir);
        
        let result = loader.load_application("nonexistent_app");
        assert!(result.is_err());
    }

    #[test]
    fn test_app_yaml_schema_validation() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let test_app_dir = apps_dir.join("test_app");
        fs::create_dir_all(&test_app_dir).unwrap();
        
        // Test valid minimal app.yaml
        let minimal_yaml = r#"
name: test_app
version: 1.0.0
description: Test application
cells: []
"#;
        fs::write(test_app_dir.join("app.yaml"), minimal_yaml).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let config = loader.load_application("test_app").unwrap();
        
        assert_eq!(config.name, "test_app");
        assert_eq!(config.version, "1.0.0");
        assert_eq!(config.description, "Test application");
        assert_eq!(config.cells.len(), 0);
        assert_eq!(config.shared_cells.len(), 0); // Default empty
    }

    #[test]
    fn test_app_yaml_with_shared_cells() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let test_app_dir = apps_dir.join("shared_test_app");
        fs::create_dir_all(&test_app_dir).unwrap();
        
        let yaml_with_shared = r#"
name: shared_test_app
version: 1.0.0
description: App with shared cells
cells: []
shared_cells:
  - cbs_sdk
  - web_server
"#;
        fs::write(test_app_dir.join("app.yaml"), yaml_with_shared).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let config = loader.load_application("shared_test_app").unwrap();
        
        assert_eq!(config.shared_cells, vec!["cbs_sdk", "web_server"]);
    }

    #[test]
    fn test_cell_with_dependencies() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let test_app_dir = apps_dir.join("deps_test_app");
        fs::create_dir_all(&test_app_dir).unwrap();
        fs::create_dir_all(test_app_dir.join("cells/dependent_cell")).unwrap();
        
        let yaml_with_deps = r#"
name: deps_test_app
version: 1.0.0
description: App with cell dependencies
cells:
  - name: dependent_cell
    path: cells/dependent_cell
    dependencies:
      - some_service
      - another_dep
"#;
        fs::write(test_app_dir.join("app.yaml"), yaml_with_deps).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let config = loader.load_application("deps_test_app").unwrap();
        
        assert_eq!(config.cells.len(), 1);
        assert_eq!(config.cells[0].dependencies, vec!["some_service", "another_dep"]);
    }
}

/// Tests for command line argument parsing for application loading
#[cfg(test)]
mod cli_argument_tests {

    #[test]
    fn test_app_parameter_parsing() {
        // Simulate command line arguments
        let args = vec![
            "body".to_string(),
            "--app".to_string(),
            "flutter_flow_web".to_string(),
        ];
        
        let app_name = parse_app_argument(&args);
        assert_eq!(app_name, Some("flutter_flow_web".to_string()));
    }

    #[test]
    fn test_app_parameter_missing() {
        let args = vec!["body".to_string(), "--demo".to_string()];
        let app_name = parse_app_argument(&args);
        assert_eq!(app_name, None);
    }

    #[test]
    fn test_app_parameter_no_value() {
        let args = vec!["body".to_string(), "--app".to_string()];
        let app_name = parse_app_argument(&args);
        assert_eq!(app_name, None);
    }

    #[test]
    fn test_app_parameter_with_other_args() {
        let args = vec![
            "body".to_string(),
            "--nats-url".to_string(),
            "nats://localhost:4222".to_string(),
            "--app".to_string(),
            "cli_greeter".to_string(),
            "--demo".to_string(),
        ];
        
        let app_name = parse_app_argument(&args);
        assert_eq!(app_name, Some("cli_greeter".to_string()));
    }

    /// Helper function to parse --app argument from command line args
    fn parse_app_argument(args: &[String]) -> Option<String> {
        for (i, arg) in args.iter().enumerate() {
            if arg == "--app" {
                return args.get(i + 1).cloned();
            }
        }
        None
    }
}
