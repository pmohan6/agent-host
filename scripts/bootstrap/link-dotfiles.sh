#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$REPO_ROOT/dotfiles/links.tsv"

if [[ ! -f "$MANIFEST" ]]; then
  exit 0
fi

# Refuse unknown existing targets before either chezmoi or the compatibility
# linker can make changes.
while IFS=$'\t' read -r source_rel target_rel; do
  [[ -z "$source_rel" || "$source_rel" == \#* ]] && continue

  source_path="$REPO_ROOT/dotfiles/$source_rel"
  target_path="$HOME/$target_rel"

  if [[ ! -e "$source_path" ]]; then
    echo "Missing dotfile source: $source_path" >&2
    exit 1
  fi

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    continue
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    echo "Refusing to overwrite existing path: $target_path" >&2
    echo "Move or merge it manually, then rerun bootstrap." >&2
    exit 1
  fi
done <"$MANIFEST"

if command -v chezmoi >/dev/null 2>&1; then
  expected_source="$REPO_ROOT/home"
  current_source="$(chezmoi source-path)"

  if [[ "$current_source" == "$expected_source" ]]; then
    echo "Applying dotfiles with chezmoi"
    chezmoi apply
  elif [[ "$current_source" == "$HOME/.local/share/chezmoi" && ! -e "$current_source" ]]; then
    echo "Initializing and applying dotfiles with chezmoi"
    chezmoi init --source "$REPO_ROOT" --apply
  else
    echo "Refusing to replace an existing chezmoi source: $current_source" >&2
    echo "Review and migrate it manually before rerunning bootstrap." >&2
    exit 1
  fi
  exit 0
fi

echo "chezmoi is not installed yet; creating compatible managed symlinks"

while IFS=$'\t' read -r source_rel target_rel; do
  [[ -z "$source_rel" || "$source_rel" == \#* ]] && continue

  source_path="$REPO_ROOT/dotfiles/$source_rel"
  target_path="$HOME/$target_rel"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    continue
  fi

  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
  echo "Linked $target_path -> $source_path"
done <"$MANIFEST"
