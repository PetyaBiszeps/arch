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

sudo systemctl disable gdm.service sddm.service lightdm.service lxdm.service 2>/dev/null || true

if systemctl list-unit-files ly.service >/dev/null 2>&1; then
  sudo systemctl enable ly.service
elif systemctl list-unit-files 'ly@.service' >/dev/null 2>&1; then
  sudo systemctl disable getty@tty2.service 2>/dev/null || true
  sudo systemctl enable ly@tty2.service
else
  echo "Could not find ly.service or ly@.service"
  exit 1
fi

echo "Ly enabled. Reboot and select niri."
