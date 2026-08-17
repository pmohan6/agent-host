#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ "$(id -u)" -eq 0 ]]; then
  echo "Refusing to configure a user environment as root." >&2
  exit 1
fi

if id -Gn | tr ' ' '\n' | grep -qx admin; then
  echo "Warning: the current account is an administrator; the intended execution account is standard." >&2
fi

create_dir() {
  local mode="$1"
  local path="$2"
  mkdir -p "$path"
  chmod "$mode" "$path"
}

create_dir 755 "$HOME/src"
create_dir 755 "$HOME/work"
create_dir 755 "$HOME/services"
create_dir 700 "$HOME/Library/Logs/agent-host"
create_dir 700 "$HOME/Library/Application Support/agent-host"
create_dir 700 "$HOME/.cache"

"$REPO_ROOT/scripts/bootstrap/link-dotfiles.sh"

touch "$HOME/.zsh_history"
chmod 600 "$HOME/.zsh_history"

if command -v mise >/dev/null 2>&1; then
  echo "Installing pinned user runtimes from ~/.config/mise/config.toml"
  mise install
else
  echo "mise is not installed yet; rerun user bootstrap after the admin package phase."
fi

echo "User bootstrap complete. No administrator or network settings were changed."
echo "Run 'make doctor' to inspect remaining work."
