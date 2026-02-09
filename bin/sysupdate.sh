#!/bin/bash

echo "Updating System..."

sudo pacman -Syu && \

echo "Done."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECK_OUTPUT=$("$SCRIPT_DIR/noctalia-check.sh")
echo "$CHECK_OUTPUT"

if echo "$CHECK_OUTPUT" | grep -q "Update available"; then
    echo "Updating Noctalia..."
    NOCTALIA_DIR="$HOME/.config/quickshell/noctalia-shell"
    mkdir -p "$NOCTALIA_DIR" && \
    curl -sL https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz | \
    tar -xz --strip-components=1 -C "$NOCTALIA_DIR"
    echo "Done."
fi
