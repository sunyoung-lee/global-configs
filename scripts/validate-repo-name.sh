#!/usr/bin/env bash
set -euo pipefail

MODE="${NAMING_ENFORCEMENT:-block}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"

if [[ "$REPO_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "PASS: repository name '$REPO_NAME' follows kebab-case"
  exit 0
fi

msg="FAIL: repository name '$REPO_NAME' must match ^[a-z0-9]+(-[a-z0-9]+)*$"
if [[ "$MODE" == "warn" ]]; then
  echo "WARN: $msg"
  exit 0
fi

echo "$msg" >&2
exit 1
