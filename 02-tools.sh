#!/bin/bash
# 02-tools.sh - Essential tools: terminal, shell, audio, system monitoring

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing kitty terminal..."
sudo pacman -S --needed --noconfirm kitty

log "Installing starship prompt..."
sudo pacman -S --needed --noconfirm starship

log "Installing MPD stack..."
sudo pacman -S --needed --noconfirm mpd mpc mpdris2 python-mutagen

log "Installing btop (system monitor)..."
sudo pacman -S --needed --noconfirm btop

log "Installing gnome-disks..."
sudo pacman -S --needed --noconfirm gnome-disk-utility

log "Installing audio stack (pipewire + pulseaudio)..."
sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber

log "Installing bluetooth stack..."
sudo pacman -S --needed --noconfirm bluez bluez-utils

log "Enabling bluetooth service..."
sudo systemctl enable --now bluetooth

log "Installing NetworkManager..."
sudo pacman -S --needed --noconfirm networkmanager

log "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager

log "Installing rmpc (MPD TUI client) via cargo..."
if command -v rmpc &>/dev/null; then
    log "rmpc already installed"
else
    cargo install rmpc
fi

log "Tools installation complete!"
