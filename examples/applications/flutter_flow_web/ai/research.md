## Research: flutter_flow_web

### Questions → Decisions
- Nav patterns in Flutter Web with Riverpod? → Use provider for active route + message-driven updates
- Bus message naming/versioning? → `cbs.<service>.<verb>.v1` in envelope schema
- UI perf on web? → Avoid heavy sync in handlers; prefer const widgets; memoize lists
- Bus monitor scalability? → Pagination/windowing of messages; bounded list length

### Notes
- Logging: concise, include correlation IDs
- Theming: use `color.withValues(alpha: x)`; modern, clean UI
- State: Riverpod for shared state; ValueNotifier for local reactive pieces

### Open items
- Decide max retained monitor messages (e.g., 500)
- Decide navbar interaction subjects (`cbs.nav.select`, `cbs.nav.highlight`)

### References
- Spec-Driven Development toolkit: [Spec Kit](https://github.com/github/spec-kit/tree/main)
- Existing app docs: `spec.md`, `tasks.md`, `cell_map.md`



