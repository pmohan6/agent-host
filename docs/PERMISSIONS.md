# Permission and exposure policy

This public file defines the approval process, not the grants present on a specific
host. Store any live permission/exposure register privately outside this repository.

## Default posture

No agent-specific privacy permission or inbound network service is implied by this
configuration. Start from deny and add only the narrowest grant needed for a
documented workflow.

## Private register fields

For every real grant, record privately:

- date and reviewed commit;
- account and exact signed application or binary;
- permission or listening address and port;
- purpose and human owner;
- accessible data or target application;
- credential scope;
- validation, expiration, and revocation procedure.

Do not copy the completed register into this public repository, an issue, or a CI
log. Public changes should describe reusable policy without naming devices, people,
accounts, addresses, or observed permissions.

## Planned review gates

| Change | Risk class | Validation before completion |
|---|---|---|
| Firewall/stealth mode | System security | Private access and physical recovery tested |
| FileVault | Encryption/recovery | Recovery material stored off-host; boot tested |
| Private-overlay enrollment | Network and identity | Device role and default-deny policy verified |
| Private SSH | Inbound private access | Named source policy and reauthentication tested |
| Screen Sharing | GUI and network | Exposure assessed; disabled by default |
| Accessibility/Recording | High-trust GUI control | Dedicated operator account and exact app identity |
| Full Disk Access | Critical data access | Exceptional written justification |
