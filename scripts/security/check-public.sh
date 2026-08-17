#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

failures=0

fail() {
  printf 'FAIL  %s\n' "$1" >&2
  failures=$((failures + 1))
}

secret_paths="$(git ls-files | grep -E '(^|/)(\.env($|\.)|\.private/|credentials/|secrets/|auth\.json$)|\.(pem|p12|pfx|key)$|\.local\.(md|json|ya?ml)$' || true)"
if [[ -n "$secret_paths" ]]; then
  fail "private or secret-like paths are tracked:\n$secret_paths"
fi

patterns=(
  '/Users/'
  '-----BEGIN (OPENSSH|RSA|EC|DSA|PGP)? ?PRIVATE KEY-----'
  '(github_pat_|gh[pousr]_)[A-Za-z0-9_]+'
  'sk-[A-Za-z0-9_-]{20,}'
  'AKIA[0-9A-Z]{16}'
  'https?://[^[:space:]]+@'
  'Mac[0-9]+,[0-9]+'
  'UID[[:space:]]+[0-9]+'
)

for pattern in "${patterns[@]}"; do
  matches="$(git grep -n -I -E -e "$pattern" -- . ':!scripts/security/check-public.sh' || true)"
  if [[ -n "$matches" ]]; then
    fail "publish-unsafe pattern '$pattern' found:\n$matches"
  fi
done

emails="$(git grep -n -I -E '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}' -- . || true)"
if [[ -n "$emails" ]]; then
  fail "email-like values are tracked:\n$emails"
fi

if ((failures > 0)); then
  printf '\nPublic-content scan failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

echo "Public-content scan passed"
