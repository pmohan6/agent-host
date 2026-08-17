# Agent host repository guidance

This repository is the source of truth for this Mac's agent-host configuration.

- Keep every live configuration change represented here in the Brewfile, scripts,
  dotfiles, launchd files, service definitions, or documentation.
- Never commit credentials, tokens, private keys, recovery keys, cookies, or
  plaintext secret values.
- Never commit host-specific observations such as usernames, UIDs, home paths,
  hardware identifiers, serial numbers, IP addresses, OS builds, application
  permission grants, account names, or backup destinations. Keep local records
  outside this public repository.
- Do not run privileged commands, change macOS security settings, grant privacy
  permissions, expose a network listener, or enroll an external service without
  explicit human approval for that phase.
- Treat files writable by the standard execution account as untrusted when an administrator
  is about to execute them. Privileged work must use a human-reviewed commit.
- Prefer idempotent scripts. A second run must not duplicate data or overwrite an
  unknown user file.
- Bind development services to loopback unless their documented design explicitly
  requires private-tailnet access.
- Use tmux for interactive persistence, per-user launchd agents for native durable
  services, and containers only where they materially improve reproducibility.
- Update `docs/INVENTORY.md` and the relevant operations/security documentation
  whenever packages, services, permissions, or exposure change.
- Before committing, run `make check` and `make doctor`.
- Before publishing, run `make public-check` and inspect the complete outgoing
  history, not only the working tree.
