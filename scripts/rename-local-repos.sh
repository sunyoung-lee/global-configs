#!/usr/bin/env bash
set -euo pipefail

APPLY=0
ROOT="${HOME}/github"

usage() {
  cat <<USAGE
Usage: $0 [--apply] [--root PATH]

Default is dry-run. Use --apply to perform renames.
USAGE
}

to_kebab() {
  local input="$1"
  printf '%s' "$input" \
    | perl -pe 's/%20/ /g; s/^\s+|\s+$//g; s/[ _]+/-/g; s/([A-Z]+)([A-Z][a-z])/$1-$2/g; s/([a-z0-9])([A-Z])/$1-$2/g; s/[^A-Za-z0-9-]+/-/g; s/-+/-/g; s/^-|-$//g; $_=lc($_);'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      APPLY=1
      shift
      ;;
    --root)
      ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$ROOT" ]]; then
  echo "Root path not found: $ROOT" >&2
  exit 1
fi

planned=0
renamed=0
skipped=0
case_only=0

while IFS= read -r -d '' src; do
  [[ -d "$src/.git" || -f "$src/.git" ]] || continue

  current_name="$(basename "$src")"
  target_name="$(to_kebab "$current_name")"

  if [[ -z "$target_name" || "$target_name" == "$current_name" ]]; then
    continue
  fi

  dst="$(dirname "$src")/$target_name"
  planned=$((planned + 1))

  if [[ -e "$dst" ]]; then
    src_inode="$(stat -f '%d:%i' "$src" 2>/dev/null || true)"
    dst_inode="$(stat -f '%d:%i' "$dst" 2>/dev/null || true)"

    if [[ -z "$src_inode" || -z "$dst_inode" || "$src_inode" != "$dst_inode" ]]; then
      echo "SKIP (target exists): '$current_name' -> '$target_name'"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  echo "PLAN: '$current_name' -> '$target_name'"
  if (( APPLY == 1 )); then
    if [[ -e "$dst" ]]; then
      temp="$(dirname "$src")/.rename-tmp-$target_name-$$"
      mv "$src" "$temp"
      mv "$temp" "$dst"
      case_only=$((case_only + 1))
    else
      mv "$src" "$dst"
    fi
    echo "DONE: '$current_name' -> '$target_name'"
    renamed=$((renamed + 1))
  fi
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo ""
echo "Summary"
echo "- planned: $planned"
if (( APPLY == 1 )); then
  echo "- renamed: $renamed"
  echo "- case-only renames: $case_only"
  echo "- skipped: $skipped"
else
  echo "- mode: dry-run"
fi
