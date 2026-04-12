#!/bin/bash
# Gamescope launcher for Sway - targets DP-2
# Requires: swaymsg, jq

W=$(swaymsg -t get_outputs | jq '.[] | select(.name == "DP-2") | .current_mode.width')
H=$(swaymsg -t get_outputs | jq '.[] | select(.name == "DP-2") | .current_mode.height')
R=$(swaymsg -t get_outputs | jq '.[] | select(.name == "DP-2") | .current_mode.refresh / 1000 | floor')
CAP_R=$(($R - 3))

# Snapshot existing window IDs before launch so we can identify the new one
BEFORE=$(swaymsg -t get_tree | jq '[.. | objects | select(.type? == "con") | .id]')

# Subscribe to window events before launching — catches the new window the instant it appears
swaymsg -t subscribe '["window"]' 2>/dev/null | \
while IFS= read -r line; do
    ID=$(printf '%s' "$line" | jq -r --argjson before "$BEFORE" \
        'select(.change == "new") | select([.container.id] - $before != []) | .container.id // empty')
    if [ -n "$ID" ]; then
        swaymsg "[con_id=$ID] move output DP-2"
        swaymsg "[con_id=$ID] focus"
        echo "$ID" > /tmp/gss_con_id
        break
    fi
done &
SUBSCRIBE_PID=$!

game-performance gamescope --force-grab-cursor -O DP-2 -W $W -H $H -w $W -h $H -r $CAP_R -f -- env MANGOHUD=1 RADV_PERFTEST=gpl PROTON_USE_NTSYNC=1 SDL_VIDEODRIVER=wayland ENABLE_GAMESCOPE_WSI=1 "$@" &
WRAPPER_PID=$!

# Wait for the subscriber to finish (window found and moved), then clean up
wait $SUBSCRIBE_PID 2>/dev/null

wait $WRAPPER_PID
