#!/bin/bash
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
passes=0
warnings=0
failures=0

pass() {
  passes=$((passes + 1))
  printf 'PASS  %s\n' "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf 'WARN  %s\n' "$1"
}

fail() {
  failures=$((failures + 1))
  printf 'FAIL  %s\n' "$1"
}

if [[ "$(uname -s)" == "Darwin" ]]; then pass "running on macOS"; else fail "host is not macOS"; fi
if [[ "$(uname -m)" == "arm64" ]]; then pass "native Apple-silicon architecture"; else warn "architecture is $(uname -m), expected arm64"; fi

if id -Gn | tr ' ' '\n' | grep -qx admin; then
  warn "current account is an administrator; agents should use a standard account"
else
  pass "current account is standard/non-admin"
fi

if csrutil status 2>/dev/null | grep -q 'enabled'; then pass "System Integrity Protection enabled"; else fail "System Integrity Protection is not confirmed enabled"; fi
if spctl --status 2>/dev/null | grep -q 'enabled'; then pass "Gatekeeper assessments enabled"; else fail "Gatekeeper is not confirmed enabled"; fi

firewall_state="$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>&1)"
if printf '%s' "$firewall_state" | grep -q 'enabled'; then pass "application firewall enabled"; else warn "application firewall disabled or unavailable"; fi

filevault_state="$(fdesetup status 2>&1)"
if printf '%s' "$filevault_state" | grep -q 'FileVault is On'; then
  pass "FileVault enabled"
elif printf '%s' "$filevault_state" | grep -q 'FileVault is Off'; then
  fail "FileVault disabled"
else
  warn "FileVault state could not be verified; check System Settings manually"
fi

if xcode-select -p >/dev/null 2>&1; then pass "Apple Command Line Tools available"; else fail "Apple Command Line Tools missing"; fi

if command -v brew >/dev/null 2>&1; then
  pass "Homebrew available at $(command -v brew)"
  brew_prefix="$(brew --prefix 2>/dev/null)"
  if [[ -n "$brew_prefix" ]]; then
    brew_owner="$(stat -f '%Su' "$brew_prefix" 2>/dev/null || echo unknown)"
    if [[ "$brew_owner" != "$(id -un)" ]]; then
      pass "Homebrew is protected from the execution account (owner: $brew_owner)"
    else
      warn "Homebrew is writable by the execution account"
    fi
  fi
  if HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file "$REPO_ROOT/Brewfile" >/dev/null 2>&1; then
    pass "Brewfile packages installed"
  else
    warn "Brewfile packages are not yet fully installed"
  fi
else
  fail "Homebrew missing"
fi

for tool in git gh tmux jq rg fd fzf tree btop mise uv shellcheck shfmt; do
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool available"
  else
    warn "$tool missing"
  fi
done

for dir in "$HOME/src" "$HOME/work" "$HOME/services" "$HOME/Library/Logs/agent-host" "$HOME/Library/Application Support/agent-host"; do
  if [[ -d "$dir" ]]; then pass "directory exists: $dir"; else warn "directory missing: $dir"; fi
done

while IFS=$'\t' read -r source_rel target_rel; do
  [[ -z "$source_rel" || "$source_rel" == \#* ]] && continue
  expected="$REPO_ROOT/dotfiles/$source_rel"
  target="$HOME/$target_rel"
  if [[ -L "$target" && "$(readlink "$target")" == "$expected" ]]; then
    pass "managed link correct: $target_rel"
  elif [[ -e "$target" || -L "$target" ]]; then
    fail "managed path exists but is not the expected link: $target"
  else
    warn "managed link missing: $target"
  fi
done < "$REPO_ROOT/dotfiles/links.tsv"

if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked_secret_paths="$(git -C "$REPO_ROOT" ls-files 2>/dev/null | grep -E '(^|/)(\.env($|\.)|credentials/|secrets/|auth\.json$)|\.(pem|p12|pfx|key)$' || true)"
  if [[ -z "$tracked_secret_paths" ]]; then pass "no secret-like paths tracked by Git"; else fail "secret-like paths tracked: $tracked_secret_paths"; fi

  if [[ -z "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
    pass "tracked working tree is clean"
  else
    warn "tracked working tree has uncommitted changes"
  fi
else
  warn "repository has not been initialized with Git"
fi

listeners="$(netstat -an -p tcp 2>/dev/null | awk '$6 == "LISTEN" {print $4}' | sort -u)"
if [[ -z "$listeners" ]]; then pass "no TCP listeners detected"; else warn "TCP listeners detected; review with make status"; fi

printf '\nRESULT: %d pass, %d warning, %d failure\n' "$passes" "$warnings" "$failures"
[[ "$failures" -eq 0 ]]
