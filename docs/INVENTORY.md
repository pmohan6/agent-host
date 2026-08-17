# Expected-state inventory

This public document describes reusable desired state. It deliberately contains no
observations from a particular computer. Obtain live state with `make status`,
`make doctor`, and `make audit`, and keep any saved output outside this repository.

## Platform

- Apple-silicon Mac running a supported macOS release with current security updates
- macOS-provided zsh and Apple Command Line Tools
- Sufficient CPU, memory, and storage for the selected workloads; exact capacity is
  intentionally local information

## Accounts and security

- A human-controlled administrator account owns Homebrew and system-wide changes
- A separate standard account owns repositories, runtimes, and user services
- SIP, Gatekeeper, FileVault, login-password requirements, and automatic security
  updates remain enabled
- Guest login and automatic login remain disabled
- The application firewall and stealth mode are enabled after private remote access
  and physical recovery have been tested
- Encrypted backups are configured; destinations and recovery material remain private

## Power and availability

- Automatic sleep while connected to power is disabled; the display may still sleep
- Wake-for-network behavior is enabled only for reviewed private-access workflows
- Restart and post-reboot recovery behavior is tested physically before the host is
  described as unattended

## Network and persistence

- No router forwarding or publicly reachable administration service
- Remote shell access uses a reviewed private-overlay policy and least privilege
- Screen Sharing remains disabled unless separately justified and documented
- Services bind to loopback by default and are represented in `config/services.yaml`
- Durable processes use reviewed user LaunchAgents or documented containers

## Managed software

- Shared command-line packages are declared in `Brewfile`
- User runtimes are pinned in `config/mise/config.toml`
- Dotfiles are applied through chezmoi's `home/` source state; the authoritative
  backing files and collision allowlist remain under `dotfiles/`
- Agent harnesses, containers, and remote-access packages are added in separately
  reviewed phases

## Privacy and drift rule

Do not add live inventory, usernames, home paths, device identifiers, IP addresses,
OS builds, installed-app lists, permission grants, account names, audit dates, or
backup destinations here. Update this expected state when the design changes and
run `make public-check` before publication.
