# launchd

Store per-user jobs under `agents/` and exceptional system-wide jobs under
`daemons/`. Every job must have a matching service inventory entry, bounded logs,
a health check, and removal instructions.
