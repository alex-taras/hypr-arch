#!/bin/bash
# Gamescope launcher for Sway - targets DP-2
# Requires: swaymsg, jq

W=$(swaymsg -t get_outputs | jq '.[] | select(.name == "DP-2") | .current_mode.width')
H=$(swaymsg -t get_outputs | jq '.[] | select(.name == "DP-2") | .current_mode.height')
R=$(swaymsg -t get_outputs | jq '.[] | select(.name == "DP-2") | .current_mode.refresh / 1000 | floor')
CAP_R=$(($R - 3))

game-performance gamescope --force-grab-cursor -O DP-2 -W $W -H $H -w $W -h $H -r $CAP_R -f -- env MANGOHUD=1 PROTON_USE_NTSYNC=1 SDL_VIDEODRIVER=wayland ENABLE_GAMESCOPE_WSI=1 "$@"
