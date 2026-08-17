#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ "$(id -u)" -eq 0 ]]; then
  echo "Refusing to run Homebrew as root." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Follow docs/RECOVERY.md as the administrator." >&2
  exit 1
fi

brew_prefix="$(brew --prefix)"
brew_owner="$(stat -f '%Su' "$brew_prefix")"
current_user="$(id -un)"

if [[ "$current_user" != "$brew_owner" ]]; then
  echo "Homebrew is owned by '$brew_owner', but the current user is '$current_user'." >&2
  echo "Log into the Homebrew-owning administrator account and rerun this phase." >&2
  exit 1
fi

if git -C "$REPO_ROOT" status --porcelain | grep -q .; then
  echo "Refusing admin bootstrap from a dirty working tree." >&2
  echo "Review and commit the exact configuration before running privileged phases." >&2
  exit 1
fi

echo "Reviewed commit: $(git -C "$REPO_ROOT" rev-parse --short HEAD)"
echo "Installing shared packages from $REPO_ROOT/Brewfile"
brew bundle --file "$REPO_ROOT/Brewfile"
brew bundle check --file "$REPO_ROOT/Brewfile"
