#!/usr/bin/env sh

set -eu

LY_CONFIG="/etc/ly/config.ini"
LY_SAVE_DIR="/var/lib/ly"

set_ly_option() {
  key="$1"
  value="$2"

  if grep -q "^#*[[:space:]]*$key[[:space:]]*=" "$LY_CONFIG"; then
    sudo sed -i "s|^#*[[:space:]]*$key[[:space:]]*=.*|$key = $value|" "$LY_CONFIG"
  else
    echo "$key = $value" | sudo tee -a "$LY_CONFIG" >/dev/null
  fi
}

echo "==> Checking Ly"

if ! yay -Q ly >/dev/null 2>&1; then
  echo "Missing ly. Make sure it is listed in packages.txt and installed."
  exit 1
fi

if [ ! -f "$LY_CONFIG" ]; then
  echo "Missing Ly config: $LY_CONFIG"
  exit 1
fi

echo "==> Creating Ly state directory"

sudo mkdir -p "$LY_SAVE_DIR"
sudo chmod 755 "$LY_SAVE_DIR"

echo "==> Configuring Ly"

set_ly_option "save" "false"
set_ly_option "save_file" "\"$LY_SAVE_DIR/save\""
set_ly_option "animation" "matrix"
set_ly_option "default_input" "password"
set_ly_option "hide_system_users" "true"

# Visual cleanup / larger-looking login screen
set_ly_option "bigclock" "true"
set_ly_option "clock" "%H:%M"
set_ly_option "hide_version_string" "true"
set_ly_option "hide_key_hints" "false"

echo "==> Validating Ly config"

if command -v ly >/dev/null 2>&1; then
  sudo ly --validate-config "$LY_CONFIG"
fi

echo "==> Ly configured"
echo "Reboot to see the Ly changes."
