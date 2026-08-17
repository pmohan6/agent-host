# Publication privacy

This repository contains reusable configuration only. A public clone must not
reveal who operates a host, which exact machine is used, what accounts or apps are
present, or how to reach it.

## Never commit

- names, email addresses, usernames, UIDs, hostnames, serial numbers, or device IDs;
- absolute home-directory paths, public or private IP addresses, tailnet/device
  names, SSH host keys, or backup destinations;
- hardware model identifiers, exact capacity, live OS build, installed-app lists,
  audit timestamps, or permission/TCC observations;
- credentials, tokens, private keys, cookies, recovery keys, `.env` files, or
  exported browser/keychain data;
- output from `make status`, `make doctor`, `make audit`, or third-party diagnostics.

Use role names such as `administrator`, `standard account`, and `daily computer` in
public documentation. Store live inventory and approval records in a private system
that is not nested inside this checkout.

## Before every public push

1. Run `make public-check`.
2. Inspect `git diff --cached` and every commit not already on the public remote.
3. Verify that ignored local files were never added in an earlier commit.
4. If sensitive data ever entered Git history, rotate affected credentials and
   rewrite the public history before pushing; deleting the current file is not
   sufficient.
