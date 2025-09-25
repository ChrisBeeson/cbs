## Envelope Validation (AJV)

### Validate Samples
```bash
npx -y ajv@8 validate \
  -c ajv-formats \
  -s .cbs-spec/docs/schemas/envelope.schema.json \
  -d .cbs-spec/docs/schemas/samples/*.json
```

Notes:
- Uses draft 2020-12; `ajv-formats` required for `uuid`.
- Samples live in `.cbs-spec/docs/schemas/samples/`.

### Sample Envelopes
See `.cbs-spec/docs/schemas/samples/envelope_ok.json` and `envelope_error.json`.

### CI Hook (optional)
Add a job step to run the command above to validate known fixtures.


