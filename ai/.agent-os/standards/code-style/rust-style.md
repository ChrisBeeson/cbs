## Rust Style

- Use `rustfmt` defaults; CI runs `cargo fmt -- --check`.
- Lint with `clippy`; fix or allow with rationale; CI uses `-D warnings`.
- Prefer explicit types on public APIs; avoid `unwrap`/`expect` in library code.
- Use early returns; handle errors with `thiserror` or `anyhow` in bins.
- Keep modules small; one responsibility per file.


