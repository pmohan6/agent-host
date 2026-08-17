# Remote access

## Target design

The daily Mac reaches the agent host only through Tailscale. No router forwarding,
public SSH, public VNC, or publicly bound agent APIs are permitted.

The preferred SSH architecture uses the open-source Tailscale CLI/daemon variant,
because Tailscale SSH's macOS server requires `tailscale` plus `tailscaled` rather
than the normal sandboxed GUI client.

## Tailnet policy

- Assign this host a dedicated `tag:agent-host` tag.
- Allow the named daily Mac or human identity to reach the agent host on SSH.
- Use Tailscale SSH `check` mode, preferably reauthentication for every new
  high-trust connection.
- Deny this host outbound tailnet access by default so untrusted code cannot use the
  host identity to move laterally to other devices.
- Add each future service port individually.

The exact policy file and device identity are credential-bearing external state and
are created only during the approved remote-access phase.

## Screen Sharing

Keep macOS Screen Sharing off initially. Enabling it creates a VNC service that may
also be reachable from the local LAN. If later required, document its interface,
firewall behavior, allowed users, Tailscale policy, and tested revocation here.

## Recovery

Maintain a local physical recovery path before changing SSH, Tailscale, the
firewall, FileVault, or power settings. FileVault on macOS 15 requires a local
preboot unlock after restart. Do not claim unattended reboot recovery until it has
been physically tested.
