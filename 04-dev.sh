#!/bin/bash
# 04-dev.sh - Development tools

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing Python..."
sudo pacman -S --needed --noconfirm python python-pip

log "Installing VSCode..."
yay -S --needed --noconfirm visual-studio-code-bin

log "Installing Zed editor..."
if command -v zed &>/dev/null; then
    log "Zed already installed"
else
    curl -f https://zed.dev/install.sh | sh
fi

log "Installing Claude Code CLI..."
if command -v claude &>/dev/null; then
    log "Claude Code already installed"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

log "Development tools installed!"
