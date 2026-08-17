# agent-host

Reproducible configuration for a dedicated Apple-silicon Mac that runs coding
agents, MCP servers, development services, and occasional local inference.

The priorities are security, reproducibility, unattended reliability, private
remote access, useful developer ergonomics, and a deliberately small software
surface.

This repository is designed to be safe to publish. It stores reusable desired
state, not facts observed on a particular host. Never commit command output from
`make status` or `make audit`, local permission registers, usernames, device
identifiers, credentials, or backup destinations. See `docs/PRIVACY.md`.

## Trust model

- The human-controlled administrator owns Homebrew and system changes.
- A standard execution account runs repositories, tools, agents, and user services.
- Administrator actions are run only from a reviewed Git commit. The administrator
  must not blindly execute mutable scripts from the execution account.
- High-trust computer-use permissions and operator credentials belong in a future
  separate standard account, not in the base agent environment.

## Bootstrap interface

From a fresh Mac, after completing the manual prerequisites in
`docs/RECOVERY.md`:

```sh
git clone <repository-url> ~/src/agent-host
cd ~/src/agent-host
./bootstrap.sh
```

The default bootstrap performs only user-owned, nonprivileged work. Shared package
installation is intentionally separate:

```sh
./bootstrap.sh --admin
```

Run the admin phase while logged into the Homebrew-owning administrator account and
only after reviewing the exact commit. Never run Homebrew as root.

## Operations

```sh
make status   # concise operational snapshot
make doctor   # expected-state and drift checks
make audit    # deeper read-only security inventory
make check    # repository validation
make public-check # scan tracked content for publish-unsafe data
```

## Current phase

The repository foundation, read-only diagnostics, safe user directories, dotfiles,
and exact runtime pins are implemented. Shared packages, downloaded runtimes,
remote access, services, and permission changes are added incrementally and
committed after verification.
