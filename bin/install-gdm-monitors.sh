#!/usr/bin/env bash
set -euo pipefail

src="${1:-dotfiles/gdm/monitors.xml}"

if [[ ! -f "$src" ]]; then
  echo "missing source file: $src" >&2
  exit 1
fi

targets=(
  "/var/lib/gdm/.config/monitors.xml"
  "/var/lib/gdm/seat0/config/monitors.xml"
)

for target in "${targets[@]}"; do
  dir="$(dirname "$target")"

  sudo install -d -m 0755 "$dir"

  if [[ -e "$target" ]]; then
    sudo cp -a "$target" "$target.bak.$(date +%Y%m%d-%H%M%S)"
  fi

  owner="$(stat -c '%u:%g' "$dir")"
  sudo install -o "${owner%:*}" -g "${owner#*:}" -m 0644 "$src" "$target"
  echo "installed $target with owner $owner"
done

echo
echo "Installed GDM monitor layout. Reboot, or restart GDM from a TTY with:"
echo "  sudo systemctl restart gdm"
