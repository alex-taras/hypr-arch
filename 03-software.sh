#!/bin/bash
# 03-software.sh - General applications and default handlers

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing pywalfox..."
yay -S --needed --noconfirm python-pywalfox

log "Installing web browsers..."
sudo pacman -S --needed --noconfirm firefox chromium

log "Installing office suite..."
sudo pacman -S --needed --noconfirm libreoffice-fresh

log "Installing PDF viewer..."
sudo pacman -S --needed --noconfirm zathura zathura-pdf-mupdf

log "Installing text editor..."
sudo pacman -S --needed --noconfirm gedit

log "Installing file manager and thumbnailers..."
sudo pacman -S --needed --noconfirm \
    nautilus \
    file-roller \
    gvfs \
    gvfs-smb \
    gvfs-mtp \
    gvfs-nfs \
    gvfs-afc \
    gvfs-goa \
    gvfs-gphoto2 \
    gvfs-dnssd \
    tumbler \
    ffmpegthumbnailer \
    poppler-glib

log "Installing media players..."
sudo pacman -S --needed --noconfirm vlc imv

log "Installing archive utilities..."
sudo pacman -S --needed --noconfirm \
    p7zip \
    unrar \
    unzip \
    zip

log "Setting nautilus as default file manager..."
xdg-mime default org.gnome.Nautilus.desktop inode/directory application/x-gnome-saved-search

log "Configuring Nautilus thumbnails..."
gsettings set org.gnome.nautilus.preferences show-image-thumbnails 'always'
gsettings set org.gnome.nautilus.preferences thumbnail-limit 500
log "Nautilus thumbnails configured (always, 500MB limit)"

log "Setting VLC as default media player..."
xdg-mime default vlc.desktop \
    video/mp4 video/x-matroska video/avi video/mpeg \
    video/quicktime video/x-msvideo video/webm \
    audio/mpeg audio/x-wav audio/flac audio/ogg \
    audio/mp4 audio/x-vorbis+ogg audio/x-opus+ogg

log "Setting imv as default image viewer..."
xdg-mime default imv.desktop \
    image/png image/jpeg image/jpg image/gif \
    image/webp image/bmp image/svg+xml

log "Setting zathura as default PDF viewer..."
xdg-mime default org.pwmt.zathura.desktop application/pdf

log "Setting gedit as default text editor..."
xdg-mime default org.gnome.gedit.desktop text/plain text/x-log text/x-readme

log "Deploying webapp shortcuts..."
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons/hicolor/scalable/apps
cp ../dotfiles/applications/chrome-*.desktop ~/.local/share/applications/ 2>/dev/null || log "No webapp shortcuts found"
cp ../dotfiles/applications/org.gnome.Nautilus.desktop ~/.local/share/applications/ 2>/dev/null || true
cp ../dotfiles/icons/chrome-*.svg ~/.local/share/icons/hicolor/scalable/apps/ 2>/dev/null || log "No webapp icons found"
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
gtk-update-icon-cache ~/.local/share/icons/hicolor/ 2>/dev/null || true

log "Software installation complete!"
log "Default handlers configured:"
log "  - Files: Nautilus"
log "  - Video/Audio: VLC"
log "  - Images: imv"
log "  - PDF: zathura"
log "  - Text: gedit"
