#!/bin/bash

# Envelope Validation Script for CBS
# Validates JSON envelopes against the CBS envelope schema

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Prefer framework docs
if [ -f "$ROOT_DIR/framework/docs/schemas/envelope.schema.json" ]; then
  SCHEMA_FILE="$ROOT_DIR/framework/docs/schemas/envelope.schema.json"
  SAMPLES_DIR="$ROOT_DIR/framework/docs/schemas/samples"
else
  SCHEMA_FILE="$SCRIPT_DIR/../docs/schemas/envelope.schema.json"
  SAMPLES_DIR="$SCRIPT_DIR/../docs/schemas/samples"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧬 CBS Envelope Validation"
echo "=========================="

# Check if ajv-cli is installed
if ! command -v ajv &> /dev/null; then
    echo -e "${YELLOW}ajv-cli not found. Will use npx to run without global install.${NC}"
    AJV_RUNNER="npx -y -p ajv-cli@5 -p ajv-formats@2 ajv"
else
    AJV_RUNNER="ajv"
fi

# Check if schema file exists
if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}Error: Schema file not found at $SCHEMA_FILE${NC}"
    exit 1
fi

echo "Schema: $SCHEMA_FILE"
echo

# Validate sample files if they exist
if [ -d "$SAMPLES_DIR" ]; then
    echo "Validating sample envelopes..."
    
    for sample_file in "$SAMPLES_DIR"/*.json; do
        if [ -f "$sample_file" ]; then
            filename=$(basename "$sample_file")
            echo -n "  $filename: "
            
            if $AJV_RUNNER validate --spec=draft2020 -c ajv-formats -s "$SCHEMA_FILE" -d "$sample_file" --verbose 2>/dev/null; then
                echo -e "${GREEN}✓ Valid${NC}"
            else
                echo -e "${RED}✗ Invalid${NC}"
                echo "    Running detailed validation..."
                $AJV_RUNNER validate --spec=draft2020 -c ajv-formats -s "$SCHEMA_FILE" -d "$sample_file" --verbose || true
                echo
            fi
        fi
    done
    echo
fi

# Validate any additional files passed as arguments
if [ $# -gt 0 ]; then
    echo "Validating provided files..."
    
    for file in "$@"; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo -n "  $file: "
            
            if $AJV_RUNNER validate --spec=draft2020 -c ajv-formats -s "$SCHEMA_FILE" -d "$file" --verbose 2>/dev/null; then
                echo -e "${GREEN}✓ Valid${NC}"
            else
                echo -e "${RED}✗ Invalid${NC}"
                echo "    Running detailed validation..."
                $AJV_RUNNER validate --spec=draft2020 -c ajv-formats -s "$SCHEMA_FILE" -d "$file" --verbose || true
                echo
            fi
        else
            echo -e "${RED}Error: File not found: $file${NC}"
        fi
    done
fi

# Show usage if no files provided
if [ $# -eq 0 ] && [ ! -d "$SAMPLES_DIR" ]; then
    echo "Usage: $0 [envelope.json ...]"
    echo
    echo "Examples:"
    echo "  $0 my_envelope.json"
    echo "  $0 envelope1.json envelope2.json"
    echo
    echo "This script validates CBS envelope JSON files against the schema."
fi

echo "Validation complete."