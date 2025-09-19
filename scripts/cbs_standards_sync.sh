#!/usr/bin/env bash
set -euo pipefail
# CBS Standards Sync (stub): copy standards and scripts to target repo(s)
# Usage: scripts/cbs_standards_sync.sh <target_dir>

SRC_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TARGET="${1-}"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target_dir>" >&2
  exit 2
fi

copy_path() {
  local rel="$1"
  mkdir -p "$TARGET/$rel"
  rsync -a --delete "$SRC_ROOT/$rel/" "$TARGET/$rel/"
}

# Canonical locations
copy_path ai/.agent-os/standards
copy_path ai/scripts
copy_path scripts

echo "Synced CBS standards to $TARGET"
