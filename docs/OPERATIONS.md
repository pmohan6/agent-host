# Operations

## Routine commands

Run from `~/src/agent-host`:

```sh
make status
make doctor
make audit
make check
```

`make status` answers what is running and reports host health, user launchd jobs,
Homebrew services, containers, listeners, and recent agent-host logs.

`make doctor` compares the machine with expected security, packages, tools,
directories, Git hygiene, and listeners. Warnings identify unfinished phases or
manual review; failures identify violated baseline controls.

`make audit` is a deeper read-only snapshot suitable for security review.
Its output contains host-specific identity and configuration data. Review it only
locally; do not commit it or upload it to public issue trackers or build logs.

## Process ownership

- Use tmux for interactive work that should survive an SSH disconnect.
- Use a documented per-user launchd agent for a native process that should restart
  automatically after login.
- Use a Compose service in the Colima VM when a Linux/container dependency or
  controlled filesystem mount is useful.
- Do not use `nohup`, undocumented cron entries, or ad hoc background shells as
  durable process management.

## Service requirements

Every automatic service needs:

- an entry in `config/services.yaml`;
- a checked-in launchd or Compose definition;
- a purpose and owner;
- an explicit listening address and port;
- a state and backup classification;
- a health check;
- bounded logs and a documented removal procedure.

## Logging

Native agent-host logs live under `~/Library/Logs/agent-host`. Container services
must configure Docker log limits. Prefer application-native rotation. A maintenance
phase will add a reviewed retention job before durable services are enabled.

## Updates

- Install shared package updates from a reviewed configuration commit as the
  Homebrew owner.
- Install language runtimes only when the pinned version configuration changes.
- Keep background security updates enabled.
- Treat major macOS upgrades as separately reviewed changes with a recovery test.

## Incident response

If an agent or repository appears compromised:

1. Stop its tmux session, launchd job, or container.
2. Disconnect Tailscale or revoke the device if network movement is a concern.
3. Revoke credentials that were accessible to the affected macOS account.
4. Preserve relevant bounded logs.
5. Prefer erasing and rebuilding the dedicated host over attempting to prove an
   extensively compromised account clean.
