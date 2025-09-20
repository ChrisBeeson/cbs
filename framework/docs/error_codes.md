## CBS Error Codes (MVP)

- **BadRequest**: Validation failed or required fields missing.
- **Timeout**: No subscriber response before request timeout.
- **NotFound**: Target resource or route not found.
- **Internal**: Unexpected error in cell or bus.

Notes:
- Return only one error per reply. No partial successes.
- Prefer concise messages; add structured `details` for context.
- Cells may add verbose, custom fields (e.g., `hint`, `path`, `offset`, `cell_trace`) under the `error` object. Avoid leaking secrets.


