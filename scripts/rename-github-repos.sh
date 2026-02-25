#!/usr/bin/env bash
set -euo pipefail

ROOT="${HOME}/github"
APPLY=0

usage() {
  cat <<USAGE
Usage: $0 [--apply] [--root PATH]

Default is dry-run. Use --apply to rename remote GitHub repositories.
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

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found" >&2
  exit 1
fi

planned=0
renamed=0
skipped=0
failed=0

while IFS= read -r -d '' repo_dir; do
  [[ -d "$repo_dir/.git" || -f "$repo_dir/.git" ]] || continue

  origin="$(git -C "$repo_dir" remote get-url origin 2>/dev/null || true)"
  [[ -n "$origin" ]] || continue

  if [[ ! "$origin" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
    echo "SKIP (non-github origin): $(basename "$repo_dir") -> $origin"
    skipped=$((skipped + 1))
    continue
  fi

  owner="${BASH_REMATCH[1]}"
  remote_name="${BASH_REMATCH[2]}"
  local_name="$(basename "$repo_dir")"
  target_name="$(to_kebab "$local_name")"

  if [[ "$remote_name" == "$target_name" ]]; then
    continue
  fi

  planned=$((planned + 1))
  echo "PLAN: $owner/$remote_name -> $owner/$target_name"

  if (( APPLY == 1 )); then
    if gh repo rename "$target_name" --repo "$owner/$remote_name"; then
      git -C "$repo_dir" remote set-url origin "https://github.com/$owner/$target_name.git"
      echo "DONE: $owner/$remote_name -> $owner/$target_name"
      renamed=$((renamed + 1))
    else
      echo "FAIL: $owner/$remote_name -> $owner/$target_name"
      failed=$((failed + 1))
    fi
  fi
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo ""
echo "Summary"
echo "- planned: $planned"
if (( APPLY == 1 )); then
  echo "- renamed: $renamed"
  echo "- failed: $failed"
  echo "- skipped: $skipped"
else
  echo "- mode: dry-run"
fi
