#!/bin/bash

# Show only if something is building
if pgrep -x "emerge" >/dev/null; then
    echo "%{F#e06c75} emerging%{F-}"
else
    echo ""
fi

