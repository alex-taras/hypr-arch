#!/bin/bash
# 05-gaming.sh - Gaming setup

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing gaming tools..."
sudo pacman -S --needed --noconfirm \
    lutris \
    steam \
    gamescope \
    gamemode \
    goverlay \
    mangohud \
    vkbasalt

log "Installing vkBasalt CAS shader..."
yay -S --needed --noconfirm pascube

log "Installing ProtonPlus..."
yay -S --needed --noconfirm protonplus

log "Gaming tools installed!"
