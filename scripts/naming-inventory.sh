#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/github}"

if [[ ! -d "$ROOT" ]]; then
  echo "Root path not found: $ROOT" >&2
  exit 1
fi

to_kebab() {
  local input="$1"
  printf '%s' "$input" \
    | perl -pe 's/%20/ /g; s/^\s+|\s+$//g; s/[ _]+/-/g; s/([A-Z]+)([A-Z][a-z])/$1-$2/g; s/([a-z0-9])([A-Z])/$1-$2/g; s/[^A-Za-z0-9-]+/-/g; s/-+/-/g; s/^-|-$//g; $_=lc($_);'
}

extract_remote_name() {
  local origin="$1"
  if [[ -z "$origin" || "$origin" == "(no-origin)" ]]; then
    printf '(none)'
    return
  fi
  printf '%s' "$origin" | sed -E 's#.*[:/]##; s#\.git$##'
}

tmp_file="$(mktemp)"
collision_file="$(mktemp)"
trap 'rm -f "$tmp_file" "$collision_file"' EXIT

while IFS= read -r -d '' dir; do
  [[ -d "$dir/.git" || -f "$dir/.git" ]] || continue

  local_name="$(basename "$dir")"
  target_name="$(to_kebab "$local_name")"
  origin_url="$(git -C "$dir" remote get-url origin 2>/dev/null || echo "(no-origin)")"
  remote_name="$(extract_remote_name "$origin_url")"

  if [[ "$local_name" == "$target_name" ]]; then
    local_status="ok"
  else
    local_status="rename-needed"
  fi

  if [[ "$remote_name" == "(none)" ]]; then
    remote_status="no-origin"
  elif [[ "$remote_name" == "$target_name" ]]; then
    remote_status="ok"
  else
    remote_status="rename-needed"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$local_name" "$target_name" "$local_status" "$remote_name" "$remote_status" "$origin_url" \
    >> "$tmp_file"
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

cut -f2 "$tmp_file" | sort | uniq -d > "$collision_file"

printf 'local_name\ttarget_name\tlocal_status\tremote_name\tremote_status\tcollision\torigin_url\n'
while IFS=$'\t' read -r local_name target_name local_status remote_name remote_status origin_url; do
  if grep -Fxq "$target_name" "$collision_file"; then
    collision="collision"
  else
    collision="ok"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$local_name" "$target_name" "$local_status" "$remote_name" "$remote_status" "$collision" "$origin_url"
done < "$tmp_file" | sort
