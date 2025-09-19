#!/usr/bin/env bash
set -euo pipefail
# DEPRECATED: Import Guard - strict import blocking is no longer enforced
# Cells can now contain internal components and modules
# The only requirement is that cells MUST communicate via bus only (no direct cell-to-cell calls)
#
# This script is kept for backward compatibility but is no longer recommended
# Usage: scripts/cell_import_guard.sh hook

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

get_app_cell() {
  # input: path like applications/<app>/cells/<cell>/...
  local p="$1"
  local app="" cell=""
  IFS='/' read -r -a parts <<<"$p"
  for i in "${!parts[@]}"; do
    if [[ "${parts[$i]}" == "applications" && $((i+3)) -lt ${#parts[@]} && "${parts[$i+2]}" == "cells" ]]; then
      app="${parts[$i+1]}"; cell="${parts[$i+3]}"; break
    fi
  done
  echo "$app/$cell"
}

scan_file() {
  local file="$1" appcell="$2"
  local app="${appcell%%/*}" cell="${appcell##*/}"
  # look for imports referencing other cells under same app
  local pattern1="applications/$app/cells/"
  if grep -nE "import .*['\"]($pattern1)([^/'\"]+)" "$file" >/dev/null 2>&1; then
    local other
    other=$(grep -nE "import .*['\"]($pattern1)([^/'\"]+)" "$file" | sed -E "s@.*$pattern1([^/'\"]+).*@\1@" | head -n1)
    if [[ "$other" != "$cell" ]]; then
      echo "Cross-cell import: $file -> $other"; return 1
    fi
  fi
  return 0
}

cmd_hook() {
  changed=$(git diff --cached --name-only --diff-filter=ACMRT)
  [ -z "$changed" ] && exit 0
  while IFS= read -r f; do
    [[ ! -f "$f" ]] && continue
    if [[ "$f" == applications/*/cells/*/* ]]; then
      appcell=$(get_app_cell "$f")
      case "$f" in
        *.dart|*.ts|*.tsx|*.rs|*.py)
          if ! scan_file "$f" "$appcell"; then
            echo "Blocked cross-cell import. Cells communicate via bus only." >&2
            echo "File: $f" >&2
            exit 1
          fi
        ;;
      esac
    fi
  done <<<"$changed"
}

case "${1-}" in
  hook) cmd_hook ;;
  *) echo "Usage: $0 hook" >&2; exit 2 ;;
 esac
