# Spec Requirements Document

> Spec: Flutter Flow Web Application with CBS Architecture
> Created: 2025-09-14

## Overview

Build a Flutter web app using CBS cells that renders "Flow" centered on the page. This establishes a minimal, end-to-end, cell-based web app with app switching.

## User Stories

### Web Application Display
As a user, I want a web page that displays "Flow" centered, proving a working CBS-powered Flutter web app.

The app loads quickly and shows a clean, modern page with "Flow" centered.

### Application Configuration Switching  
As a developer, I want to switch between CBS applications via directories, so I can deploy different cell compositions without code changes.

Run `cargo run -p body -- --app applications/flutter_flow_web` to load that app, or `cargo run -p body -- --app applications/cli_greeter` to load the CLI greeter. Each app is self-contained with its own cells, config, and docs.

### Cell-Based Web Architecture
As a developer, I want isolated, testable cells for web apps to ensure maintainability and scale.

Each function (UI, state, events, data) is a separate cell communicating via the CBS bus for independent dev, test, and deploy.

## Spec Scope

1. **Flutter Web Cell Framework** — Flutter/Dart cells for web UI and interactions
2. **Web UI Rendering Cell** — Render "Flow" with modern, responsive styling
3. **Self-Contained Applications** — Apps under `applications/` with cells, config, docs
4. **Application Loader** — Body loads apps from directories
5. **Flutter Web Integration** — Flutter web compile integrated with CBS build

## Out of Scope

- Interactivity beyond displaying text
- Auth/session management
- Database integration
- Mobile builds (web-only)
- Advanced styling/animations

## Expected Deliverable

1. **Working Flutter Web App** — Deployable app that displays "Flow"
2. **App Switching** — Switch between `applications/flutter_flow_web/` and `applications/cli_greeter/` via CLI
3. **Cell Architecture** — Flutter web built as isolated, testable CBS cells
