#!/bin/bash
set -u

print_value() {
  local label="$1"
  shift
  local value
  value="$("$@" 2>&1 | head -1)"
  printf '%-28s %s\n' "$label" "${value:-unavailable}"
}

printf '[identity]\n'
print_value "user" id -un
print_value "groups" id -Gn
printf '%-28s %s\n' "admin member" "$(id -Gn | tr ' ' '\n' | grep -qx admin && echo yes || echo no)"

printf '\n[platform security]\n'
print_value "SIP" csrutil status
print_value "Gatekeeper" spctl --status
print_value "FileVault" fdesetup status
print_value "firewall" /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
print_value "firewall stealth" /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode

printf '\n[updates]\n'
print_value "update schedule" softwareupdate --schedule
for key in AutomaticDownload AutomaticallyInstallMacOSUpdates ConfigDataInstall CriticalUpdateInstall; do
  value="$(defaults read /Library/Preferences/com.apple.SoftwareUpdate "$key" 2>/dev/null || echo unknown)"
  printf '%-28s %s\n' "$key" "$value"
done

printf '\n[power on AC]\n'
pmset -g custom 2>/dev/null | sed -n '/AC Power:/,$p'

printf '\n[backup]\n'
tmutil destinationinfo 2>&1 | head -5

printf '\n[TCP listeners]\n'
netstat -an -p tcp 2>/dev/null | awk '$6 == "LISTEN" {print $4}' | sort -u

printf '\n[agent-host launchd jobs]\n'
launchctl list 2>/dev/null | awk 'NR == 1 || $3 ~ /^com\.agent-host\./'

printf '\nManual checks still required: FileVault recovery-key custody, TCC permissions,\n'
printf 'Sharing settings, screen-lock delay, and physical post-reboot recovery.\n'
