#!/bin/bash
# Polybar syslog-tail.sh — compact, no net, expanded system events

LOG_FILE="/var/log/messages"
IGNORE_PATTERNS="dbus|pulseaudio|pipewire|bluetoothd|rtkit|systemd|ntpd|avahi|cron-anacron|dhcpcd|NetworkManager"
AGE_SEC=60

# Polybar color formatting
RED="%{F#F5A3A3}"      # pastel red  (cron)
PURPLE="%{F#CBA6F7}"   # pastel purple (system)
RESET="%{F-}"

# Get latest relevant line from the last minute
LINE=$(awk -v d="$(date --date="-$AGE_SEC sec" '+%b %_d %H:%M')" '$0 ~ d' "$LOG_FILE" \
    | grep -vE "$IGNORE_PATTERNS" | tail -n 1)

[ -z "$LINE" ] && exit 0

# Detect and simplify message type
if echo "$LINE" | grep -q "CRON"; then
    MSG=$(echo "$LINE" | sed -E 's/.*CMD \(\/usr\/local\/bin\/cron-log //' | sed 's/\)$//')
    MSG=$(echo "$MSG" | sed -E 's/emerge (--pretend|-p)? ?--update --deep --newuse @world/world chk/')
    MSG=$(echo "$MSG" | sed -E 's/emerge --update --deep --newuse @world/world upd/')
    MSG=$(echo "$MSG" | sed -E 's/emerge --depclean/depclean/')
    MSG=$(echo "$MSG" | sed -E 's/run-crons/cron run/')
    TAG="${RED}[cron]${RESET}"

elif echo "$LINE" | grep -q "kernel"; then
    MSG=$(echo "$LINE" | sed -E 's/.*kernel: //')

    # Common kernel/system events made readable
    MSG=$(echo "$MSG" | sed -E 's/usb [0-9]-[0-9]: new .+ device.*/USB in/')
    MSG=$(echo "$MSG" | sed -E 's/usb [0-9]-[0-9]: USB disconnect.*/USB out/')
    MSG=$(echo "$MSG" | sed -E 's/Attached SCSI removable disk.*/Drive in/')
    MSG=$(echo "$MSG" | sed -E 's/sd[a-z]: .*synchronized.*/Drive sync/')
    MSG=$(echo "$MSG" | sed -E 's/ext4 filesystem on.*/Mount ok/')
    MSG=$(echo "$MSG" | sed -E 's/Unmounting filesystem.*/Unmount/')
    MSG=$(echo "$MSG" | sed -E 's/thermal_zone[0-9]: .*critical.*/Temp high!/')
    MSG=$(echo "$MSG" | sed -E 's/CPU[0-9]: Core temperature.*/Temp warn/')
    MSG=$(echo "$MSG" | sed -E 's/amd-pstate: CPU.*/CPU freq adj/')
    MSG=$(echo "$MSG" | sed -E 's/power_supply.*online.*/Power on/')
    MSG=$(echo "$MSG" | sed -E 's/power_supply.*offline.*/Power off/')
    MSG=$(echo "$MSG" | sed -E 's/Resuming from hibernation.*/Resume/')
    MSG=$(echo "$MSG" | sed -E 's/Suspend entry.*/Suspend/')
    TAG="${PURPLE}[sys]${RESET}"

elif echo "$LINE" | grep -E -q "emerge|portage"; then
    MSG=$(echo "$LINE" | sed -E 's/.*emerge: //' | sed -E 's/.*>>> //')
    MSG=$(echo "$MSG" | sed -E 's/.*completed.*/Pkg done/')
    MSG=$(echo "$MSG" | sed -E 's/.*Installing (.+)-.*/Pkg \1/')
    MSG=$(echo "$MSG" | sed -E 's/.*Cleaning.*/Pkg clean/')
    TAG="${PURPLE}[sys]${RESET}"

else
    MSG=$(echo "$LINE" | sed -E 's/^[A-Z][a-z]* *[0-9]* *[0-9:]* [^ ]* //')
    TAG="${PURPLE}[sys]${RESET}"
fi

# Truncate long messages
SHORT_MSG=$(echo "$MSG" | cut -c1-40)
echo "$TAG $SHORT_MSG"

