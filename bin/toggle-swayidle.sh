#!/bin/bash

if pgrep -x swayidle > /dev/null; then
    killall swayidle
else
    swayidle -w \
        timeout 300  'qs -c noctalia-shell ipc call lockScreen lock' \
        timeout 600  'swaymsg "output * dpms off"' \
        resume       'swaymsg "output * dpms on"' \
        before-sleep 'qs -c noctalia-shell ipc call lockScreen lock' &
fi

sleep 0.3

if pgrep -x swayidle > /dev/null; then
    qs -c noctalia-shell ipc call toast send '{"title": "Swayidle", "body": "Started", "icon": "alarm"}'
else
    qs -c noctalia-shell ipc call toast send '{"title": "Swayidle", "body": "Stopped", "icon": "alarm"}'
fi
