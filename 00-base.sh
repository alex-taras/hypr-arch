#!/bin/bash
# 00-base.sh - Base system setup for Arch: yay, build tools, git, rust, go

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing base development tools..."
sudo pacman -S --needed --noconfirm base-devel git

log "Installing yay (AUR helper)..."
if command -v yay &>/dev/null; then
    log "yay already installed"
else
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
    log "yay installed"
fi

log "Installing Rust..."
if command -v cargo &>/dev/null; then
    log "Rust already installed"
else
    sudo pacman -S --needed --noconfirm rust
fi

log "Installing Go..."
if command -v go &>/dev/null; then
    log "Go already installed"
else
    sudo pacman -S --needed --noconfirm go
fi

log "Installing NFS client..."
sudo pacman -S --needed --noconfirm nfs-utils

log "Enabling NFS services..."
sudo systemctl enable --now rpcbind
sudo systemctl enable --now nfs-client.target

log "Installing Samba..."
sudo pacman -S --needed --noconfirm samba smbclient wsdd

log "Enabling SSH..."
sudo pacman -S --needed --noconfirm openssh
sudo systemctl enable --now sshd

log "Installing zsh..."
sudo pacman -S --needed --noconfirm zsh

cp "$(dirname "$0")/dotfiles/.zshrc" ~/.zshrc

log "Switching default shell to zsh..."
chsh -s /usr/bin/zsh

log "Base system setup complete!"
log "Please reboot for the shell change to take effect."
