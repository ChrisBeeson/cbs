#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
SCHEMA="$PROJECT_ROOT/ai/docs/schemas/envelope.schema.json"
SAMPLES="$PROJECT_ROOT/ai/docs/schemas/samples/*.json"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required. Install Node.js (includes npx)." >&2
  exit 1
fi

exec npx -y ajv@8 validate -c ajv-formats -s "$SCHEMA" -d "$SAMPLES"


