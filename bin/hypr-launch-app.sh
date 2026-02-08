#!/bin/bash
# Launch an application or focus it if already running
# Usage: launch-app.sh <executable> [window-class]

if [ -z "$1" ]; then
    echo "Usage: $0 <executable> [window-class]"
    echo "Example: $0 firefox"
    echo "Example: $0 nemo filemanager"
    exit 1
fi

EXECUTABLE="$1"
WINDOW_CLASS="${2:-$1}"

# Check if the app is already running by checking window class
WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg p "$WINDOW_CLASS" '.[]|select(.class|test("\\b" + $p + "\\b";"i"))|.address' | head -n1)

if [[ -n $WINDOW_ADDRESS ]]; then
    # Window exists, focus it
    hyprctl dispatch focuswindow "address:$WINDOW_ADDRESS"
else
    # Window doesn't exist, launch new instance
    exec "$EXECUTABLE" &
fi
