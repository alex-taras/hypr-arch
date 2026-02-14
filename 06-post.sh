#!/bin/bash
# 06-post.sh - Post-install configuration: NFS, Samba, dotfiles, bin scripts

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Setting up NFS mount for music library..."
sudo mkdir -p /mnt/music

log "Creating systemd mount unit..."
sudo tee /etc/systemd/system/mnt-music.mount > /dev/null <<'EOF'
[Unit]
Description=NFS Music Library Mount
After=network-online.target
Wants=network-online.target

[Mount]
What=192.168.1.137:/volume1/VIDEO_1/MUSIC
Where=/mnt/music
Type=nfs
Options=defaults,noatime,_netdev

[Install]
WantedBy=multi-user.target
EOF

log "Enabling NFS mount..."
sudo systemctl daemon-reload
sudo systemctl enable mnt-music.mount
if ! mountpoint -q /mnt/music; then
    sudo systemctl start mnt-music.mount
    log "NFS music library mounted"
else
    log "NFS mount already active"
fi

log "Deploying dotfiles..."
if [ -d ./dotfiles ]; then
    cp -r ./dotfiles/* ~/.config/
    log "Dotfiles deployed to ~/.config/"
else
    log "No dotfiles directory found, skipping"
fi

log "Deploying bin scripts..."
if [ -d ./bin ]; then
    mkdir -p ~/bin
    cp -r ./bin/* ~/bin/
    chmod +x ~/bin/*.sh
    log "Bin scripts deployed to ~/bin/"
else
    log "No bin directory found, skipping"
fi

log "Adding ~/bin to PATH in .zshrc..."
if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    log "~/bin added to PATH in .zshrc"
else
    log "~/bin already in PATH"
fi

log "Deploying desktop files and icons..."
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons/hicolor/scalable/apps
cp "$(dirname "$0")"/apps/*.desktop ~/.local/share/applications/
cp "$(dirname "$0")"/apps/icons/*.svg ~/.local/share/icons/hicolor/scalable/apps/
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
gtk-update-icon-cache ~/.local/share/icons/hicolor/ 2>/dev/null || true

log "Preparing MPD data directory..."
mkdir -p ~/.mpd/playlists

log "Configuring MPD to wait for NFS mount..."
mkdir -p ~/.config/systemd/user/mpd.service.d
cat > ~/.config/systemd/user/mpd.service.d/network-wait.conf <<'EOF'
[Unit]
After=network-online.target

[Service]
ExecStartPre=/bin/sh -c 'until mountpoint -q /mnt/music; do sleep 2; done'
Restart=on-failure
RestartSec=5
EOF

log "Disabling system MPD service..."
sudo systemctl stop mpd 2>/dev/null || true
sudo systemctl disable mpd 2>/dev/null || true

log "Enabling user MPD and mpDris2 services..."
systemctl --user daemon-reload
systemctl --user enable mpd
systemctl --user enable mpDris2
if mountpoint -q /mnt/music; then
    systemctl --user start mpd && systemctl --user start mpDris2 \
        || log "Services will start on next login"
else
    log "NFS mount not available yet, services will start on next login"
fi

log "Configuring Samba shares..."
if [ ! -f /etc/samba/smb.conf ]; then
    log "Creating base smb.conf..."
    sudo tee /etc/samba/smb.conf > /dev/null <<'EOF'
[global]
    workgroup = WORKGROUP
    server string = Samba Server
    security = user
    map to guest = never
    passdb backend = tdbsam
    client min protocol = SMB2
    client max protocol = SMB3
EOF
fi

if sudo pdbedit -L | grep -q "^$USER:"; then
    log "Samba user $USER already exists"
else
    log "Adding Samba user $USER (you will be prompted for password)..."
    sudo smbpasswd -a $USER
fi

if ! grep -q "\[DATA\]" /etc/samba/smb.conf; then
    log "Adding DATA share to smb.conf..."
    sudo tee -a /etc/samba/smb.conf > /dev/null <<EOF

[DATA]
    path = /mnt/DATA
    valid users = $USER
    read only = no
    browseable = yes
    create mask = 0644
    directory mask = 0755
EOF
else
    log "DATA share already configured"
fi

if ! grep -q "\[WORK\]" /etc/samba/smb.conf; then
    log "Adding WORK share to smb.conf..."
    sudo tee -a /etc/samba/smb.conf > /dev/null <<EOF

[WORK]
    path = /mnt/WORK
    valid users = $USER
    read only = no
    browseable = yes
    create mask = 0644
    directory mask = 0755
EOF
else
    log "WORK share already configured"
fi

log "Enabling Samba services..."
sudo systemctl enable --now smb nmb wsdd
sudo systemctl restart smb nmb wsdd

log "Configuring firewall for SMB and network discovery..."
sudo pacman -S --needed --noconfirm ufw
sudo ufw allow 137/udp comment 'NetBIOS Name Service'
sudo ufw allow 138/udp comment 'NetBIOS Datagram'
sudo ufw allow 139/tcp comment 'NetBIOS Session'
sudo ufw allow 445/tcp comment 'SMB'
sudo ufw allow 5353/udp comment 'mDNS'
sudo ufw allow 3702/udp comment 'WS-Discovery'
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 53 comment 'Waydroid DNS'
sudo ufw allow 67/udp comment 'Waydroid DHCP'
sudo ufw default allow FORWARD
sudo ufw --force enable
sudo systemctl enable --now ufw
log "Firewall configured and enabled"

log "Post-install configuration complete!"
log "NFS mount: /mnt/music"
log "Samba shares: DATA (/mnt/DATA), WORK (/mnt/WORK)"
