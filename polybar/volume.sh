#!/bin/bash

# Get Volume and Mute state using pactl for PipeWire
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)')

# Logic based on your original script
if [ "$MUTE" = "yes" ]; then
    # Muted Icon (Nerd Font: nf-md-volume_off)
    ICON="󰝟"
    VOL="MUTED"
else
    # Active Icon (Nerd Font: nf-fa-volume_up)
    ICON=""
    VOL="$VOL%"
fi

# Output formatted exactly like your original script
printf "%s %s" "$ICON" "$VOL"
