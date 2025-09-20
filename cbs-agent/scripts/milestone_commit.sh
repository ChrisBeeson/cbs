#!/usr/bin/env bash
set -euo pipefail

msg=${1:-}
if [ -z "$msg" ]; then
  echo "Usage: scripts/milestone_commit.sh '<type>(scope): message'" >&2
  exit 1
fi

git add -A
git commit -m "$msg"


