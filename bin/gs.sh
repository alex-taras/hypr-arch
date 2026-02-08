#!/bin/bash
# Gamescope launcher - window will be moved to DP-2 via Hyprland rules
W=$(hyprctl monitors -j | jq '.[] | select(.name == "DP-2") | .width')
H=$(hyprctl monitors -j | jq '.[] | select(.name == "DP-2") | .height')
R=$(hyprctl monitors -j | jq '.[] | select(.name == "DP-2") | .refreshRate | floor')

game-performance gamescope --force-grab-cursor -W $W -H $H -r $R --adaptive-sync -f -- env MANGOHUD=1 DXVK_ASYNC=1 "$@"
