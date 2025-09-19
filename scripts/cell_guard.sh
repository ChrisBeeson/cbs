#!/usr/bin/env bash
set -euo pipefail

# DEPRECATED: Cell Guard - strict commit isolation is no longer enforced
# Cells are now allowed to be larger and contain internal components
# The only requirement is that cells MUST communicate via bus only
#
# This script is kept for backward compatibility but is no longer recommended
# Usage:
#   scripts/cell_guard.sh start <cell_path>
#   scripts/cell_guard.sh stop
#   scripts/cell_guard.sh status
# Internals:
#   Writes allowed prefix to .cell_guard and installs git hooks that call this script.

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GUARD_FILE="$ROOT_DIR/.cell_guard"
HOOK_PRE_COMMIT="$ROOT_DIR/.git/hooks/pre-commit"
HOOK_PRE_PUSH="$ROOT_DIR/.git/hooks/pre-push"
MARKER="# cell_guard managed"

install_hook() {
  local hook_path="$1"
  mkdir -p "$(dirname "$hook_path")"
  cat >"$hook_path" <<EOF
#!/usr/bin/env sh
$MARKER
exec "$(git rev-parse --show-toplevel)/scripts/cell_guard.sh" hook
EOF
  chmod +x "$hook_path"
}

remove_hook_if_managed() {
  local hook_path="$1"
  if [ -f "$hook_path" ] && grep -q "$MARKER" "$hook_path"; then
    rm -f "$hook_path"
  fi
}

cmd_start() {
  if [ "${1-}" = "" ]; then
    echo "Usage: $0 start <cell_path>" >&2
    exit 2
  fi
  local input_path="$1"
  # Normalize to project-relative path
  local abs_input
  abs_input="$(cd "$ROOT_DIR" && cd "$input_path" 2>/dev/null && pwd || true)"
  if [ "${abs_input}" = "" ]; then
    echo "Error: path not found: $input_path" >&2
    exit 1
  fi
  local rel
  rel="${abs_input#$ROOT_DIR/}"
  echo "ALLOW_PREFIX=$rel" >"$GUARD_FILE"
  install_hook "$HOOK_PRE_COMMIT"
  install_hook "$HOOK_PRE_PUSH"
  echo "Cell guard ON for '$rel'"
}

cmd_stop() {
  rm -f "$GUARD_FILE"
  remove_hook_if_managed "$HOOK_PRE_COMMIT"
  remove_hook_if_managed "$HOOK_PRE_PUSH"
  echo "Cell guard OFF"
}

cmd_status() {
  if [ -f "$GUARD_FILE" ]; then
    . "$GUARD_FILE"
    echo "Cell guard: ON (ALLOW_PREFIX=${ALLOW_PREFIX-})"
  else
    echo "Cell guard: OFF"
  fi
}

cmd_hook() {
  # Allow normal commits if guard is off
  if [ ! -f "$GUARD_FILE" ]; then
    exit 0
  fi
  . "$GUARD_FILE"
  prefix="${ALLOW_PREFIX-}"
  if [ -z "$prefix" ]; then
    exit 0
  fi

  # Staged files for commit (on pre-commit) or push check uses index as well
  changed=$(git diff --cached --name-only --diff-filter=ACMRT)
  [ -z "$changed" ] && exit 0

  # Validate every changed path starts with prefix/
  bad=""
  while IFS= read -r f; do
    case "$f" in
      "$prefix"|$prefix/*)
        ;;
      *)
        bad="$bad\n$f"
        ;;
    esac
  done <<EOF
$changed
EOF

  if [ -n "$bad" ]; then
    echo "Cell guard blocked commit. Only files under '$prefix' are allowed while guard is ON." >&2
    echo "Offending paths:" >&2
    # shellcheck disable=SC2001
    echo "$bad" | sed '1d' >&2
    echo "Hint: run 'scripts/cell_guard.sh stop' to disable guard." >&2
    exit 1
  fi
}

subcmd="${1-}"
case "$subcmd" in
  start) shift; cmd_start "$@" ;;
  stop) cmd_stop ;;
  status) cmd_status ;;
  hook) cmd_hook ;;
  *) echo "Usage: $0 {start <cell_path>|stop|status}" >&2; exit 2 ;;
esac


