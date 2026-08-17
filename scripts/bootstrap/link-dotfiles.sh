#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$REPO_ROOT/dotfiles/links.tsv"

if [[ ! -f "$MANIFEST" ]]; then
  exit 0
fi

while IFS=$'\t' read -r source_rel target_rel; do
  [[ -z "$source_rel" || "$source_rel" == \#* ]] && continue

  source_path="$REPO_ROOT/dotfiles/$source_rel"
  target_path="$HOME/$target_rel"

  if [[ ! -e "$source_path" ]]; then
    echo "Missing dotfile source: $source_path" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    continue
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    echo "Refusing to overwrite existing path: $target_path" >&2
    echo "Move or merge it manually, then rerun bootstrap." >&2
    exit 1
  fi

  ln -s "$source_path" "$target_path"
  echo "Linked $target_path -> $source_path"
done < "$MANIFEST"
