#!/bin/bash
# 01a-sway.sh - Sway and Noctalia shell installation for Arch

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Installing GTK/Qt theming dependencies..."
sudo pacman -S --needed --noconfirm adw-gtk-theme qt5ct qt6ct kvantum breeze-icons

log "Installing SwayFX..."
yay -S --needed --noconfirm swayfx

log "Installing Noctalia shell dependencies..."
yay -S --needed --noconfirm \
    noctalia-qs \
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

log "Installing Sway extras..."
sudo pacman -S --needed --noconfirm \
    swayidle \
    grim \
    slurp \
    jq \
    polkit-gnome \
    xdg-desktop-portal-gtk \
    thunar

log "Restoring Sway dotfiles..."
mkdir -p ~/.config/sway
cp "$SCRIPT_DIR/dotfiles/sway/config"   ~/.config/sway/config
cp "$SCRIPT_DIR/dotfiles/sway/noctalia" ~/.config/sway/noctalia

log "Applying GTK dark theme system-wide..."
sudo mkdir -p /etc/gtk-3.0 /etc/gtk-2.0
sudo tee /etc/gtk-3.0/settings.ini > /dev/null <<'EOF'
[Settings]
gtk-theme-name = Adwaita-dark
gtk-application-prefer-dark-theme = true
EOF
sudo tee /etc/gtk-2.0/gtkrc > /dev/null <<'EOF'
gtk-theme-name = "Adwaita-dark"
EOF

log "Setting system environment variables..."
# Add only if not already present
grep -q 'GTK_THEME' /etc/environment || echo 'GTK_THEME=Adwaita:dark' | sudo tee -a /etc/environment
grep -q 'XDG_CURRENT_DESKTOP' /etc/environment || echo 'XDG_CURRENT_DESKTOP=sway' | sudo tee -a /etc/environment

log "Applying gsettings dark theme..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

log "Sway and Noctalia setup complete!"
