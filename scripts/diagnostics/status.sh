#!/bin/bash
set -u

section() {
  printf '\n[%s]\n' "$1"
}

optional() {
  command -v "$1" >/dev/null 2>&1
}

section "host"
printf 'macOS:      %s (%s)\n' "$(sw_vers -productVersion)" "$(sw_vers -buildVersion)"
printf 'arch:       %s\n' "$(uname -m)"
printf 'user:       %s (uid %s)\n' "$(id -un)" "$(id -u)"
printf 'uptime:     %s\n' "$(uptime | sed 's/^[[:space:]]*//')"

section "storage"
df -h / | awk 'NR == 1 || NR == 2'

section "memory pressure"
if command -v memory_pressure >/dev/null 2>&1; then
  memory_pressure 2>/dev/null | awk '/System-wide memory free percentage/ {print; found=1} END {if (!found) print "unavailable"}'
else
  echo "unavailable"
fi

section "agent-host launchd jobs"
jobs="$(launchctl list 2>/dev/null | awk 'NR == 1 || $3 ~ /^com\.agent-host\./')"
if [[ "$(printf '%s\n' "$jobs" | wc -l | tr -d ' ')" -le 1 ]]; then
  echo "none"
else
  printf '%s\n' "$jobs"
fi

section "Homebrew services"
if optional brew; then
  brew services list 2>/dev/null || echo "unavailable"
else
  echo "Homebrew unavailable"
fi

section "containers"
if optional colima; then
  colima status 2>&1 || true
else
  echo "Colima not installed"
fi
if optional docker; then
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>&1 || true
else
  echo "Docker CLI not installed"
fi

section "TCP listeners"
listeners="$(netstat -an -p tcp 2>/dev/null | awk '$6 == "LISTEN" {print $4}' | sort -u)"
if [[ -n "$listeners" ]]; then
  printf '%s\n' "$listeners"
else
  echo "none detected"
fi

section "recent agent-host logs"
log_root="$HOME/Library/Logs/agent-host"
if [[ -d "$log_root" ]]; then
  find "$log_root" -maxdepth 2 -type f -mtime -2 -print 2>/dev/null | sort | tail -20
else
  echo "log directory not created"
fi
