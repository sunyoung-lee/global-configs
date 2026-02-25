#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/github}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CONFIGS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORT_DIR="$GLOBAL_CONFIGS_ROOT/reports"

mkdir -p "$REPORT_DIR"

repo_inventory="$REPORT_DIR/repo-naming-inventory.tsv"
code_baseline="$REPORT_DIR/js-ts-naming-baseline.tsv"

"$SCRIPT_DIR/naming-inventory.sh" "$ROOT" > "$repo_inventory"

printf 'repo\tsummary\n' > "$code_baseline"
for d in "$ROOT"/*; do
  [[ -d "$d" ]] || continue
  [[ -d "$d/.git" || -f "$d/.git" ]] || continue

  repo="$(basename "$d")"
  [[ "$repo" == "global-configs" ]] && continue

  if [[ ! -f "$d/scripts/naming-check.mjs" ]]; then
    printf '%s\tmissing-script\n' "$repo" >> "$code_baseline"
    continue
  fi

  line="$(cd "$d" && NAMING_ENFORCEMENT=warn node scripts/naming-check.mjs 2>/dev/null | tail -n 1)"
  if [[ -z "$line" ]]; then
    line="PASS or no-output"
  fi

  printf '%s\t%s\n' "$repo" "$line" >> "$code_baseline"
done

echo "Written: $repo_inventory"
echo "Written: $code_baseline"
