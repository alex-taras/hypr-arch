#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIDTH=$(( ${COLUMNS:-$(tput cols)} - 2 ))

# Check for system updates
UPDATES=$(checkupdates 2>/dev/null)
UPDATE_COUNT=$(echo "$UPDATES" | grep -c '^.\+' )

if [[ "$UPDATE_COUNT" -gt 0 ]]; then
    gum style --width "$WIDTH" --border normal --border-foreground 6 --padding "1 2" \
        "System:" \
        "" \
        "$UPDATE_COUNT update(s) available." \
        "" \
        "$UPDATES"
    sudo pacman -Syu --noconfirm
else
    gum style --width "$WIDTH" --border normal --border-foreground 6 --padding "1 2" \
        "System:" \
        "" \
        "Up to date."
fi

# Check for Flatpak updates
FLATPAK_UPDATES=$(flatpak remote-ls --updates 2>/dev/null)
FLATPAK_COUNT=$(echo "$FLATPAK_UPDATES" | grep -c '^.\+')

if [[ "$FLATPAK_COUNT" -gt 0 ]]; then
    gum style --width "$WIDTH" --border normal --border-foreground 6 --padding "1 2" \
        "Flatpak:" \
        "" \
        "$FLATPAK_COUNT update(s) available." \
        "" \
        "$FLATPAK_UPDATES"
    flatpak update -y
else
    gum style --width "$WIDTH" --border normal --border-foreground 6 --padding "1 2" \
        "Flatpak:" \
        "" \
        "Up to date."
fi

# Check for Noctalia updates
CHECK_OUTPUT=$("$SCRIPT_DIR/noctalia-check.sh")
echo "$CHECK_OUTPUT"

if echo "$CHECK_OUTPUT" | grep -q "Update available"; then
    NOCTALIA_DIR="$HOME/.config/quickshell/noctalia-shell"
    mkdir -p "$NOCTALIA_DIR" && \
    curl -sL https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz | \
    tar -xz --strip-components=1 -C "$NOCTALIA_DIR"
fi

gum spin --title "Wrapping up..." -- sleep 10
