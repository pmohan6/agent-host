#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while IFS= read -r -d '' script; do
  bash -n "$script"
done < <(find "$REPO_ROOT" -type f -name '*.sh' -print0)

if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r -d '' script; do
    shellcheck "$script"
  done < <(find "$REPO_ROOT" -type f -name '*.sh' -print0)
else
  echo "WARN: shellcheck not installed; syntax-only shell validation completed"
fi

while IFS= read -r -d '' plist; do
  plutil -lint "$plist" >/dev/null
done < <(find "$REPO_ROOT/launchd" -type f -name '*.plist' -print0)

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle list --file "$REPO_ROOT/Brewfile" >/dev/null
fi

"$REPO_ROOT/scripts/security/check-public.sh"

echo "Repository checks passed"
