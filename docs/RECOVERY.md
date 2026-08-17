# Recovery from a factory-reset Mac

The recovery objective is that losing the host is inconvenient, not catastrophic.

## 1. Manual prerequisites

1. Erase/install a supported macOS release using normal Apple recovery.
2. Create a human-controlled administrator account.
3. Create a separate standard account named `agent`.
4. Keep automatic login off and personal iCloud data out of the execution account.
5. Install all current security updates.
6. Verify SIP and Gatekeeper are enabled.
7. Enable FileVault, store its recovery key away from this Mac, and ensure the
   intended human-controlled accounts can unlock the volume.
8. Install Apple Command Line Tools.
9. Install Homebrew as the administrator, not as root, in `/opt/homebrew`.

## 2. Restore the configuration repository

As the standard execution account:

```sh
mkdir -p ~/src
git clone <repository-url> ~/src/agent-host
cd ~/src/agent-host
git verify-commit HEAD  # when signed commits are configured
make check
```

## 3. Restore shared packages

Review the checked-out commit as the administrator. Use an administrator-owned
checkout or otherwise ensure the exact files cannot change between review and
execution. Then, as the Homebrew-owning administrator—not root—run:

```sh
./bootstrap.sh --admin
```

## 4. Restore the agent user

As the standard execution account:

```sh
cd ~/src/agent-host
./bootstrap.sh
make doctor
```

This creates managed directories, links only known-absent dotfiles, and later
installs pinned user runtimes. When chezmoi is available from the Brewfile, the
bootstrap initializes this checkout as its source and applies the dotfiles
automatically. The collision preflight refuses to replace unknown existing files.

To inspect or reapply dotfiles later:

    chezmoi status
    chezmoi diff
    chezmoi apply

## 5. Restore credentials

Restore credentials interactively from their authoritative systems:

- enroll Tailscale using the approved device identity and tag;
- restore scoped GitHub or service bot access;
- recreate macOS Keychain items;
- authorize an optional dedicated 1Password agent vault;
- rotate credentials if the prior Mac was lost or compromise is possible.

Never copy an old shell history, plaintext `.env`, browser profile, or unrestricted
personal credential bundle.

## 6. Restore repositories and valuable state

1. Clone important repositories from their remotes.
2. Restore only documented service state from the encrypted backup.
3. Rebuild container images, language environments, model caches, and disposable
   worktrees rather than restoring them.
4. Confirm filesystem ownership belongs to the standard execution account.

## 7. Restore macOS permissions

Use `docs/PERMISSIONS.md` as the allowlist. Grant each TCC permission manually to
the exact documented application and account. Do not bulk-restore a TCC database or
grant a generic terminal broad access.

## 8. Restore services and remote access

1. Reapply the reviewed Tailscale ACL.
2. Test SSH from the daily Mac before changing sleep or firewall settings.
3. Load documented user LaunchAgents and start approved Compose services.
4. Verify every listener is expected and privately reachable only as designed.
5. Configure encrypted Time Machine and its exclusions.

## 9. Validate

```sh
make check
make doctor
make status
make audit
```

Perform a controlled reboot, verify FileVault unlock and login behavior, confirm
Tailscale recovery, reconnect over SSH, and check that only documented services
return.
