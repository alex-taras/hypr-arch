#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIDTH=$(( ${COLUMNS:-$(tput cols)} - 2 ))
NOCTALIA_DIR="$HOME/.config/quickshell/noctalia-shell"
UPDATE_SERVICE="$NOCTALIA_DIR/Services/Noctalia/UpdateService.qml"

# ============================================================
# PHASE 1: Check all updates
# ============================================================

# Check for system updates
UPDATES=$(checkupdates 2>/dev/null)
UPDATE_COUNT=$(echo "$UPDATES" | grep -c '^.\+' )

# Check for Flatpak updates
FLATPAK_UPDATES=$(flatpak remote-ls --updates 2>/dev/null)
FLATPAK_COUNT=$(echo "$FLATPAK_UPDATES" | grep -c '^.\+')

# Check for Noctalia updates
NOCTALIA_INSTALLED=""
if [[ -f "$UPDATE_SERVICE" ]]; then
    NOCTALIA_INSTALLED=$(grep -oP 'baseVersion:\s*"\K[^"]+' "$UPDATE_SERVICE")
fi

NOCTALIA_LATEST=$(curl -s https://api.github.com/repos/noctalia-dev/noctalia-shell/releases/latest | grep -oP '"tag_name":\s*"\Kv?[^"]+')
NOCTALIA_LATEST="${NOCTALIA_LATEST#v}"

NOCTALIA_HAS_UPDATE=0
if [[ -n "$NOCTALIA_LATEST" && -n "$NOCTALIA_INSTALLED" && "$NOCTALIA_INSTALLED" != "$NOCTALIA_LATEST" ]]; then
    NOCTALIA_HAS_UPDATE=1
fi

# ============================================================
# PHASE 2: Display consolidated update summary
# ============================================================

OUTPUT_LINES=()
OUTPUT_LINES+=("Update Summary")
OUTPUT_LINES+=("")

# System section
OUTPUT_LINES+=("System:")
if [[ "$UPDATE_COUNT" -gt 0 ]]; then
    OUTPUT_LINES+=("  $UPDATE_COUNT update(s) available")
    while IFS= read -r line; do
        [[ -n "$line" ]] && OUTPUT_LINES+=("  $line")
    done <<< "$UPDATES"
else
    OUTPUT_LINES+=("  Up to date")
fi
OUTPUT_LINES+=("")

# Flatpak section
OUTPUT_LINES+=("Flatpak:")
if [[ "$FLATPAK_COUNT" -gt 0 ]]; then
    OUTPUT_LINES+=("  $FLATPAK_COUNT update(s) available")
    while IFS= read -r line; do
        [[ -n "$line" ]] && OUTPUT_LINES+=("  $line")
    done <<< "$FLATPAK_UPDATES"
else
    OUTPUT_LINES+=("  Up to date")
fi
OUTPUT_LINES+=("")

# Noctalia section
OUTPUT_LINES+=("Noctalia:")
if [[ -z "$NOCTALIA_INSTALLED" ]]; then
    OUTPUT_LINES+=("  Not installed")
elif [[ "$NOCTALIA_HAS_UPDATE" -eq 1 ]]; then
    OUTPUT_LINES+=("  Update available: $NOCTALIA_INSTALLED → $NOCTALIA_LATEST")
else
    OUTPUT_LINES+=("  Up to date ($NOCTALIA_INSTALLED)")
fi

# Display the consolidated box
printf '%s\n' "${OUTPUT_LINES[@]}" | gum style --width "$WIDTH" --border normal --border-foreground 6 --padding "1 2"

# ============================================================
# PHASE 3: Perform updates
# ============================================================

# System update
if [[ "$UPDATE_COUNT" -gt 0 ]]; then
    echo ""
    echo "Updating system..."
    sudo pacman -Syu --noconfirm
fi

# Flatpak update
if [[ "$FLATPAK_COUNT" -gt 0 ]]; then
    echo ""
    echo "Updating Flatpak..."
    flatpak update -y
fi

# Noctalia update
if [[ "$NOCTALIA_HAS_UPDATE" -eq 1 ]]; then
    echo ""
    echo "Updating Noctalia..."
    mkdir -p "$NOCTALIA_DIR" && \
    curl -sL https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz | \
    tar -xz --strip-components=1 -C "$NOCTALIA_DIR"
fi

gum spin --title "Wrapping up..." -- sleep 10
