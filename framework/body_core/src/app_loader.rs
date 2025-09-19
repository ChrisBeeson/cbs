use serde::{Deserialize, Serialize};
use std::path::{Path, PathBuf};
use thiserror::Error;

/// Application configuration loaded from app.yaml
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppConfig {
    pub name: String,
    pub version: String,
    pub description: String,
    pub cells: Vec<CellConfig>,
    #[serde(default)]
    pub shared_cells: Vec<String>,
}

/// Cell configuration within an application
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct CellConfig {
    pub name: String,
    pub path: String,
    #[serde(default)]
    pub dependencies: Vec<String>,
}

/// Errors that can occur during application loading
#[derive(Debug, Error)]
pub enum AppLoadError {
    #[error("Application directory not found: {0}")]
    DirectoryNotFound(String),
    #[error("app.yaml not found in directory: {0}")]
    ConfigNotFound(String),
    #[error("Invalid app.yaml format: {0}")]
    InvalidConfig(String),
    #[error("Cell directory not found: {0}")]
    CellNotFound(String),
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("YAML parsing error: {0}")]
    Yaml(#[from] serde_yaml::Error),
}

/// Application loader for discovering and loading CBS applications
pub struct AppLoader {
    applications_dir: PathBuf,
}

impl AppLoader {
    /// Create a new application loader
    pub fn new<P: AsRef<Path>>(applications_dir: P) -> Self {
        Self {
            applications_dir: applications_dir.as_ref().to_path_buf(),
        }
    }

    /// Discover all available applications
    pub fn discover_applications(&self) -> Result<Vec<String>, AppLoadError> {
        if !self.applications_dir.exists() {
            return Ok(vec![]);
        }

        let mut apps = Vec::new();
        for entry in std::fs::read_dir(&self.applications_dir)? {
            let entry = entry?;
            if entry.file_type()?.is_dir() {
                let app_name = entry.file_name().to_string_lossy().to_string();
                let app_config_path = entry.path().join("app.yaml");
                if app_config_path.exists() {
                    apps.push(app_name);
                }
            }
        }
        apps.sort();
        Ok(apps)
    }

    /// Load application configuration from directory
    pub fn load_application(&self, app_name: &str) -> Result<AppConfig, AppLoadError> {
        let app_dir = self.applications_dir.join(app_name);
        
        if !app_dir.exists() {
            return Err(AppLoadError::DirectoryNotFound(app_name.to_string()));
        }

        let config_path = app_dir.join("app.yaml");
        if !config_path.exists() {
            return Err(AppLoadError::ConfigNotFound(app_name.to_string()));
        }

        let config_content = std::fs::read_to_string(&config_path)?;
        let config: AppConfig = serde_yaml::from_str(&config_content)?;

        // Validate cell paths exist
        self.validate_cell_paths(&app_dir, &config)?;

        Ok(config)
    }

    /// Validate that all cell paths in the configuration exist
    fn validate_cell_paths(&self, app_dir: &Path, config: &AppConfig) -> Result<(), AppLoadError> {
        for cell in &config.cells {
            let cell_path = app_dir.join(&cell.path);
            if !cell_path.exists() {
                return Err(AppLoadError::CellNotFound(format!(
                    "{} ({})", 
                    cell.name, 
                    cell.path
                )));
            }
        }
        Ok(())
    }

    /// Get the full path to an application directory
    pub fn get_app_path(&self, app_name: &str) -> PathBuf {
        self.applications_dir.join(app_name)
    }
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            name: "unnamed".to_string(),
            version: "0.1.0".to_string(),
            description: "CBS Application".to_string(),
            cells: vec![],
            shared_cells: vec![],
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    fn create_test_app_structure() -> (TempDir, AppLoader) {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        // Create test app directory structure
        let test_app_dir = apps_dir.join("test_app");
        fs::create_dir_all(&test_app_dir).unwrap();
        fs::create_dir_all(test_app_dir.join("cells/test_cell")).unwrap();
        
        // Create app.yaml
        let app_config = AppConfig {
            name: "test_app".to_string(),
            version: "1.0.0".to_string(),
            description: "Test application".to_string(),
            cells: vec![CellConfig {
                name: "test_cell".to_string(),
                path: "cells/test_cell".to_string(),
                dependencies: vec![],
            }],
            shared_cells: vec![],
        };
        
        let config_yaml = serde_yaml::to_string(&app_config).unwrap();
        fs::write(test_app_dir.join("app.yaml"), config_yaml).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        (temp_dir, loader)
    }

    #[test]
    fn app_loader_creation() {
        let loader = AppLoader::new("./applications");
        assert_eq!(loader.applications_dir, PathBuf::from("./applications"));
    }

    #[test]
    fn discover_applications_empty_directory() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let apps = loader.discover_applications().unwrap();
        assert_eq!(apps, Vec::<String>::new());
    }

    #[test]
    fn discover_applications_nonexistent_directory() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("nonexistent");
        
        let loader = AppLoader::new(&apps_dir);
        let apps = loader.discover_applications().unwrap();
        assert_eq!(apps, Vec::<String>::new());
    }

    #[test]
    fn discover_applications_with_valid_apps() {
        let (_temp_dir, loader) = create_test_app_structure();
        let apps = loader.discover_applications().unwrap();
        assert_eq!(apps, vec!["test_app"]);
    }

    #[test]
    fn discover_applications_ignores_directories_without_app_yaml() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        // Create directory without app.yaml
        fs::create_dir_all(apps_dir.join("invalid_app")).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let apps = loader.discover_applications().unwrap();
        assert_eq!(apps, Vec::<String>::new());
    }

    #[test]
    fn load_application_success() {
        let (_temp_dir, loader) = create_test_app_structure();
        let config = loader.load_application("test_app").unwrap();
        
        assert_eq!(config.name, "test_app");
        assert_eq!(config.version, "1.0.0");
        assert_eq!(config.description, "Test application");
        assert_eq!(config.cells.len(), 1);
        assert_eq!(config.cells[0].name, "test_cell");
        assert_eq!(config.cells[0].path, "cells/test_cell");
    }

    #[test]
    fn load_application_directory_not_found() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let result = loader.load_application("nonexistent");
        
        assert!(matches!(result, Err(AppLoadError::DirectoryNotFound(_))));
    }

    #[test]
    fn load_application_config_not_found() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        fs::create_dir_all(apps_dir.join("no_config_app")).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let result = loader.load_application("no_config_app");
        
        assert!(matches!(result, Err(AppLoadError::ConfigNotFound(_))));
    }

    #[test]
    fn load_application_invalid_yaml() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let bad_app_dir = apps_dir.join("bad_yaml_app");
        fs::create_dir_all(&bad_app_dir).unwrap();
        fs::write(bad_app_dir.join("app.yaml"), "invalid: yaml: content: [").unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let result = loader.load_application("bad_yaml_app");
        
        assert!(matches!(result, Err(AppLoadError::Yaml(_))));
    }

    #[test]
    fn load_application_cell_not_found() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        let app_dir = apps_dir.join("missing_cell_app");
        fs::create_dir_all(&app_dir).unwrap();
        
        let app_config = AppConfig {
            name: "missing_cell_app".to_string(),
            version: "1.0.0".to_string(),
            description: "App with missing cell".to_string(),
            cells: vec![CellConfig {
                name: "missing_cell".to_string(),
                path: "cells/missing_cell".to_string(),
                dependencies: vec![],
            }],
            shared_cells: vec![],
        };
        
        let config_yaml = serde_yaml::to_string(&app_config).unwrap();
        fs::write(app_dir.join("app.yaml"), config_yaml).unwrap();
        
        let loader = AppLoader::new(&apps_dir);
        let result = loader.load_application("missing_cell_app");
        
        assert!(matches!(result, Err(AppLoadError::CellNotFound(_))));
    }

    #[test]
    fn app_config_serialization_roundtrip() {
        let config = AppConfig {
            name: "test".to_string(),
            version: "1.0.0".to_string(),
            description: "Test app".to_string(),
            cells: vec![CellConfig {
                name: "cell1".to_string(),
                path: "cells/cell1".to_string(),
                dependencies: vec!["dep1".to_string()],
            }],
            shared_cells: vec!["shared1".to_string()],
        };
        
        let yaml = serde_yaml::to_string(&config).unwrap();
        let deserialized: AppConfig = serde_yaml::from_str(&yaml).unwrap();
        
        assert_eq!(config, deserialized);
    }

    #[test]
    fn app_config_default_values() {
        let yaml = r#"
name: minimal
version: 1.0.0
description: Minimal app
cells: []
"#;
        
        let config: AppConfig = serde_yaml::from_str(yaml).unwrap();
        assert_eq!(config.shared_cells, Vec::<String>::new());
    }

    #[test]
    fn get_app_path() {
        let loader = AppLoader::new("./applications");
        let path = loader.get_app_path("test_app");
        assert_eq!(path, PathBuf::from("./applications/test_app"));
    }

    #[test]
    fn cell_config_with_dependencies() {
        let cell = CellConfig {
            name: "test_cell".to_string(),
            path: "cells/test".to_string(),
            dependencies: vec!["dep1".to_string(), "dep2".to_string()],
        };
        
        assert_eq!(cell.dependencies.len(), 2);
        assert!(cell.dependencies.contains(&"dep1".to_string()));
        assert!(cell.dependencies.contains(&"dep2".to_string()));
    }

    #[test]
    fn multiple_applications_discovery_sorted() {
        let temp_dir = TempDir::new().unwrap();
        let apps_dir = temp_dir.path().join("applications");
        fs::create_dir_all(&apps_dir).unwrap();
        
        // Create multiple app directories with app.yaml files
        for app_name in ["zebra_app", "alpha_app", "beta_app"] {
            let app_dir = apps_dir.join(app_name);
            fs::create_dir_all(&app_dir).unwrap();
            
            let config = AppConfig {
                name: app_name.to_string(),
                version: "1.0.0".to_string(),
                description: format!("{} description", app_name),
                cells: vec![],
                shared_cells: vec![],
            };
            
            let config_yaml = serde_yaml::to_string(&config).unwrap();
            fs::write(app_dir.join("app.yaml"), config_yaml).unwrap();
        }
        
        let loader = AppLoader::new(&apps_dir);
        let apps = loader.discover_applications().unwrap();
        
        assert_eq!(apps, vec!["alpha_app", "beta_app", "zebra_app"]);
    }
}
