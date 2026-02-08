#!/bin/bash
# 01-hyprland.sh - Hyprland and Noctalia shell installation for Arch

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing GTK/Qt theming dependencies..."
sudo pacman -S --needed --noconfirm adw-gtk-theme qt5ct qt6ct kvantum breeze-icons

log "Installing Hyprland..."
sudo pacman -S --needed --noconfirm hyprland

log "Installing Noctalia shell dependencies..."
yay -S --needed --noconfirm \
    quickshell \
    brightnessctl \
    git \
    imagemagick \
    python \
    ddcutil \
    cliphist \
    wlsunset \
    xdg-desktop-portal \
    python3 \
    evolution-data-server

log "Installing Cascadia Code Nerd Font..."
yay -S --needed --noconfirm ttf-cascadia-code-nerd

log "Installing Noctalia shell..."
mkdir -p ~/.config/quickshell/noctalia-shell
curl -sL https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz | tar -xz --strip-components=1 -C ~/.config/quickshell/noctalia-shell

log "Installing Hyprland extras..."
sudo pacman -S --needed --noconfirm \
    hypridle \
    hyprlock \
    grim \
    slurp \
    polkit-gnome

log "Hyprland and Noctalia setup complete!"
