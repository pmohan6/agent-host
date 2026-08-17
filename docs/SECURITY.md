# Security model

## Threat model

Assume an agent may execute malicious or compromised repository code. The design
therefore protects the administrator account, personal data, unrelated network
resources, and high-value credentials from the normal execution account.

The standard account boundary protects the administrator and other users, but it
does not isolate two processes running as the same user. Any secret delivered to
one arbitrary process under the `agent` UID should be considered obtainable by
other hostile code running under that UID.

## Baseline controls

- Keep SIP, Gatekeeper, FileVault, automatic security updates, and login-password
  requirements enabled.
- Enable the application firewall and stealth mode after remote access has a tested
  recovery path.
- Never use automatic login.
- Do not expose SSH, VNC, agent APIs, model servers, or container ports publicly.
- Bind development services to `127.0.0.1` by default.
- Use Tailscale ACLs for explicitly approved private reachability.
- Run agents as the standard account, never as root.

## Administrator boundary

Homebrew is intentionally owned by the administrator. The agent can use shared
binaries but cannot silently replace them. The administrator must review the commit
and working-tree cleanliness before running `./bootstrap.sh --admin`.

Do not use `sudo brew`. Log into the Homebrew-owning account and run Homebrew as
that user.

## Secrets

Actual secret values never belong in Git, shell startup files, shell history,
launchd plists, Compose files, committed `.env` files, or plaintext documentation.

Preferred mechanisms:

1. macOS Keychain items scoped to a service and account.
2. Runtime credential commands that inject a secret only into the intended process.
3. Dedicated bot identities, GitHub Apps, fine-grained tokens, and narrowly scoped
   API credentials.
4. Optionally, 1Password CLI with a dedicated agent vault or service account—not a
   personal vault.

Background services that use the login Keychain start only after interactive login.
Recovery documentation records how a human restores credentials without recording
their values.

## Progressive trust

| Level | Mechanism | Credential posture |
|---|---|---|
| Sandbox | Workspace sandbox; container for reproducibility; VM for hostile code | None |
| Developer | Standard execution account and selected repositories | Repo-scoped development credentials |
| Operator | Future separate standard account | Selected external systems and GUI permissions |
| Highly trusted | Human-supervised session | Explicit, temporary grants where possible |

## Computer-use permissions

| Permission | Capability | Blast radius | Default |
|---|---|---|---|
| Accessibility | Read/control much of the GUI and synthesize input | Broad account control | Deny |
| Screen Recording | Capture visible screen and potentially sensitive content | All visible applications | Deny |
| Automation / Apple Events | Control each approved target application | Target app's data/actions | Deny |
| Full Disk Access | Read protected app data and user/system locations | Nearly all local data | Deny |
| Input Monitoring | Observe keyboard/mouse input | Credentials and private activity | Deny |
| Local Network | Discover and contact LAN services | Adjacent devices/services | Deny unless needed |

Grant permissions to the narrowest signed application or dedicated launcher. Do not
grant them to iTerm, Terminal, a general shell, or an entire agent suite merely for
convenience.

## Browser

Use a dedicated unsynced agent profile. It must not contain personal passwords,
cookies, payment details, unrelated accounts, or passkeys. Automation may instead
use an isolated persistent browser-data directory owned by the relevant trust-level
account.

## iCloud and personal data

The execution account should remain signed out of iCloud by default. Do not enable
Messages, Mail, Photos, Contacts, Passwords/Passkeys, Safari sync, iCloud Drive, or
Desktop/Documents sync without a documented workflow and explicit approval.
