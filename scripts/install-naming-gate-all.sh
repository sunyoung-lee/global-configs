#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/github}"
OVERWRITE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --overwrite)
      OVERWRITE=1
      shift
      ;;
    --root)
      ROOT="$2"
      shift 2
      ;;
    *)
      if [[ "$1" != "$ROOT" ]]; then
        ROOT="$1"
      fi
      shift
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CONFIGS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -d "$ROOT" ]]; then
  echo "Root path not found: $ROOT" >&2
  exit 1
fi

processed=0
updated=0
skipped=0

while IFS= read -r -d '' repo_dir; do
  [[ -d "$repo_dir/.git" || -f "$repo_dir/.git" ]] || continue

  repo_name="$(basename "$repo_dir")"
  if [[ "$repo_name" == "global-configs" ]]; then
    continue
  fi

  processed=$((processed + 1))
  echo "Repo: $repo_name"

  mkdir -p "$repo_dir/scripts" "$repo_dir/.github/workflows"

  copy_file() {
    local src="$1"
    local dst="$2"

    if [[ -f "$dst" && "$OVERWRITE" -eq 0 ]]; then
      echo "  SKIP: $(basename "$dst") exists"
      skipped=$((skipped + 1))
      return
    fi

    cp "$src" "$dst"
    echo "  OK: $(basename "$dst") installed"
    updated=$((updated + 1))
  }

  copy_file "$GLOBAL_CONFIGS_ROOT/scripts/validate-repo-name.sh" "$repo_dir/scripts/validate-repo-name.sh"
  chmod +x "$repo_dir/scripts/validate-repo-name.sh"

  copy_file "$GLOBAL_CONFIGS_ROOT/templates/naming-check.mjs" "$repo_dir/scripts/naming-check.mjs"
  chmod +x "$repo_dir/scripts/naming-check.mjs"

  copy_file "$GLOBAL_CONFIGS_ROOT/templates/naming-standard.yml" "$repo_dir/.github/workflows/naming-standard.yml"
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo ""
echo "Summary"
echo "- repos processed: $processed"
echo "- files installed/updated: $updated"
echo "- files skipped: $skipped"
