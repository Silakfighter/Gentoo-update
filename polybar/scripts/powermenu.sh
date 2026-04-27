#!/bin/bash
# Gentoo + OpenRC Power Menu (TokyoNight Theme)

theme="$HOME/.config/rofi/themes/tokyonight.rasi"
rofi_cmd=(rofi -theme "$theme" -dmenu -i -p "Power Menu:")

options=$'  Reboot\n  Power Off\n  Logout\n󰜺  Cancel'

chosen=$(printf "%b" "$options" | "${rofi_cmd[@]}")

case "$chosen" in
  "  Reboot")
    /usr/bin/sudo /usr/sbin/reboot
    ;;
  "  Power Off")
    /usr/bin/sudo /usr/sbin/poweroff
    ;;
  "  Logout")
    bspc quit
    ;;
  *)
    exit 0
    ;;
esac

