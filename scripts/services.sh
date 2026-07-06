#!/usr/bin/env sh

set -eu

has_unit() {
  unit="$1"

  systemctl list-unit-files --type=service --no-legend "$unit" 2>/dev/null |
    grep -q "^$unit"
}

echo "==> Checking Ly"

if ! yay -Q ly >/dev/null 2>&1; then
  echo "Missing ly. Make sure it is listed in packages.txt and installed."
  exit 1
fi

echo "==> Checking niri session"

if [ ! -f /usr/share/wayland-sessions/niri.desktop ]; then
  echo "Missing /usr/share/wayland-sessions/niri.desktop"
  echo "Make sure niri is installed."
  exit 1
fi

echo "==> Enabling Ly"

sudo systemctl disable \
  gdm.service \
  sddm.service \
  lightdm.service \
  lxdm.service \
  2>/dev/null || true

if has_unit "ly.service"; then
  sudo systemctl enable ly.service
elif has_unit "ly@.service"; then
  sudo systemctl disable getty@tty2.service 2>/dev/null || true
  sudo systemctl enable ly@tty2.service
else
  echo "Could not find ly.service or ly@.service"
  exit 1
fi

echo "==> Enabling RTKit"

if yay -Q rtkit >/dev/null 2>&1; then
  sudo systemctl enable --now rtkit-daemon.service
else
  echo "Missing rtkit. Make sure it is listed in packages.txt and installed."
  exit 1
fi

echo "==> Disabling initrd NetworkManager service if present"

if has_unit "NetworkManager-initrd.service"; then
  sudo systemctl disable --now NetworkManager-initrd.service 2>/dev/null || true
fi

echo "==> Services configured"
echo "Reboot and select niri in Ly."
