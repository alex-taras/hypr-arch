#!/bin/bash
# Launch a website as a standalone app using Chromium
# If the app is already running, focus it instead of launching a new instance

if [ -z "$1" ]; then
    echo "Usage: $0 <URL> [app-name]"
    echo "Example: $0 https://youtube.com youtube"
    exit 1
fi

URL="$1"
APP_NAME="${2:-webapp}"

# Check if the webapp is already running by checking window class
WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg p "$APP_NAME" '.[]|select(.class|test("\\b" + $p + "\\b";"i"))|.address' | head -n1)

if [[ -n $WINDOW_ADDRESS ]]; then
    # Window exists, focus it
    hyprctl dispatch focuswindow "address:$WINDOW_ADDRESS"
else
    # Window doesn't exist, launch new instance
    # Create isolated profile directory
    PROFILE_DIR="$HOME/.local/share/webapps/$APP_NAME"
    mkdir -p "$PROFILE_DIR"
    
    exec chromium-browser \
        --app="$URL" \
        --user-data-dir="$PROFILE_DIR" \
        --class="$APP_NAME" \
        --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36" \
        --widevine-path=/usr/lib/chromium/libwidevinecdm.so \
        --disable-features=Translate
fi
