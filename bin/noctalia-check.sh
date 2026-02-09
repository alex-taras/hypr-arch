#!/bin/bash

NOCTALIA_DIR="$HOME/.config/quickshell/noctalia-shell"
UPDATE_SERVICE="$NOCTALIA_DIR/Services/Noctalia/UpdateService.qml"

# Get installed version
INSTALLED=""
if [[ -f "$UPDATE_SERVICE" ]]; then
    INSTALLED=$(grep -oP 'baseVersion:\s*"\K[^"]+' "$UPDATE_SERVICE")
fi

# Get latest version from GitHub
LATEST=$(curl -s https://api.github.com/repos/noctalia-dev/noctalia-shell/releases/latest | grep -oP '"tag_name":\s*"\Kv?[^"]+')
LATEST="${LATEST#v}"

# Determine if update is available
if [[ -n "$LATEST" && -n "$INSTALLED" && "$INSTALLED" != "$LATEST" ]]; then
    HAS_UPDATE=1
else
    HAS_UPDATE=0
fi

# Count-only mode: just output 1 or 0
if [[ "$1" == "--count" ]]; then
    echo "$HAS_UPDATE"
    exit 0
fi

# Normal mode: verbose output
if [[ -z "$LATEST" ]]; then
    echo "Failed to fetch latest version (GitHub API rate limit?)."
    exit 1
fi

if [[ -z "$INSTALLED" ]]; then
    echo "Noctalia is not installed."
    echo "Latest:    $LATEST"
    exit 2
fi

echo "Installed: $INSTALLED"
echo "Latest:    $LATEST"

if [[ "$HAS_UPDATE" -eq 1 ]]; then
    echo "Update available!"
else
    echo "Up to date."
fi
