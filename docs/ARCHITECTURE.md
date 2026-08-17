# Architecture

## Objective

This Mac is a dedicated, always-on agent host. It is not a mirror of a personal
computer. Configuration should be rebuildable from Git, while credentials and
valuable runtime state have explicit restore paths.

## Accounts and trust boundaries

### Administrator

The administrator is human-controlled and owns Homebrew and macOS-wide changes.
It is used for reviewed package installation, operating-system maintenance,
FileVault, firewall, networking, and privacy-permission approval.

Administrator commands must be run from a reviewed commit. Because autonomous
agents can edit their own checkout, an administrator must not blindly execute a
script merely because it lives in this repository.

### Standard execution account

This account is standard/non-admin. It owns repositories, worktrees, language
runtimes, agent state, and user services. Normal autonomous work runs here.

### Future operator

If computer use or high-value external credentials are required, create a separate
standard account. Grant that account only the relevant Accessibility, Screen
Recording, Automation, browser, and service permissions. Do not grant these to a
generic terminal in the base execution account.

## Filesystem layout

| Path | Purpose | Recovery class |
|---|---|---|
| `~/src/agent-host` | This configuration repository | Git |
| `~/src` | Long-lived repositories | Git remotes/backups |
| `~/work` | Disposable worktrees and scratch work | Recreate |
| `~/services` | Service checkouts and deployment entrypoints | Git plus state backup |
| `~/Library/Application Support/agent-host` | Valuable service state | Encrypted backup |
| `~/Library/Logs/agent-host` | Bounded user-service logs | Disposable |
| `~/.codex`, similar | Harness-specific state | Selective; never blindly commit |

## Execution model

- tmux preserves interactive terminal sessions.
- Per-user launchd LaunchAgents run documented native services after login.
- System LaunchDaemons are exceptional, administrator-reviewed, and configured to
  drop privileges to a standard account when possible.
- Colima supplies a Linux VM for Docker-compatible workloads where containers add
  reproducibility or dependency isolation.
- Host-native execution remains appropriate for macOS automation, Apple GPU/Metal
  workloads, and normal development tools.

Containers are not a hostile-code security boundary. Untrusted repositories need a
disposable VM with no home-directory share, no personal credentials, and restricted
network egress.

## Configuration layers

- `Brewfile`: shared base packages installed by the Homebrew-owning administrator.
- `config/`: declarative configuration for runtimes and services.
- `dotfiles/`: user configuration linked through an explicit manifest.
- `launchd/`: every auto-started native service.
- `services/`: container and application service definitions.
- `scripts/`: idempotent bootstrap, diagnostics, maintenance, and security checks.
- `docs/`: design, inventory, operations, recovery, and approval records.

## Codex configuration

`AGENTS.md` contains the repository's durable behavioral rules. Project Codex
configuration, if added, belongs under `.codex/` and must retain conservative
sandbox and approval defaults. External systems should be connected only through
individually approved MCP servers or app connectors with least-privilege accounts.
