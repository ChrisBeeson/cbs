# CBS Subject Naming Guide

## Format
- Always `cbs.{service}.{verb}`
- Exactly 3 segments; snake_case for all parts

## Service name
- Describe the capability/domain, not technology
- Prefer `domain_capability`
- Convention: end with `_{category}` when practical
  - Categories: `ui`, `logic`, `storage`, `io`, `integration`
  - Examples: `task_ui`, `auth_logic`, `task_storage`, `files_io`, `stripe_integration`

## Verb name
- Action-oriented, present tense (e.g., `render`, `create`, `get_profile`)
- Keep it short; avoid generic verbs like `do`, `run`
- Group related actions under the same service

## Examples
- Good: `cbs.task_ui.render`, `cbs.auth_logic.login`, `cbs.task_storage.save`
- Also good (no category suffix needed): `cbs.notifications.send_email`
- Avoid: `cbs.user.get` (too vague), `cbs.task.create_new_task_record` (too long)

## Grouping & scaling
- Use the service segment for grouping; keep the single bus
- Use NATS queue groups and JetStream streams for scaling/persistence

## Enforcement
- The spec validator warns if a service name doesn’t end with `_{category}` when the cell’s category is one of the standard categories
- Set `CBS_ENFORCE_SERVICE_SUFFIX=1` to make this rule an error in CI

