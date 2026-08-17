#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [--user|--admin|--check]

  --user   Apply only nonprivileged, user-owned configuration (default).
  --admin  Install Brewfile packages as the Homebrew-owning admin; never as root.
  --check  Run repository validation and the configuration doctor.
USAGE
}

mode="${1:---user}"

case "$mode" in
  --user)
    exec "$REPO_ROOT/scripts/bootstrap/user.sh"
    ;;
  --admin)
    exec "$REPO_ROOT/scripts/bootstrap/admin.sh"
    ;;
  --check)
    "$REPO_ROOT/tests/check.sh"
    exec "$REPO_ROOT/scripts/diagnostics/doctor.sh"
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 64
    ;;
esac
