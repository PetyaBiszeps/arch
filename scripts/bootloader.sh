#!/usr/bin/env sh

set -eu

ARCH_DIR="$(cd "$(dirname "$0")/.." && pwd)"

THEME_NAME="fallout"
THEME_SRC="$ARCH_DIR/themes/$THEME_NAME"
THEME_DEST="/boot/grub/themes/$THEME_NAME"
GRUB_DEFAULT="/etc/default/grub"

set_grub_option() {
  key="$1"
  value="$2"

  if grep -q "^#*$key=" "$GRUB_DEFAULT"; then
    sudo sed -i "s|^#*$key=.*|$key=$value|" "$GRUB_DEFAULT"
  else
    echo "$key=$value" | sudo tee -a "$GRUB_DEFAULT" >/dev/null
  fi
}

echo "==> Checking /boot"

if ! findmnt /boot >/dev/null 2>&1; then
  echo "Missing /boot mount. Mount ESP before configuring GRUB."
  exit 1
fi

echo "==> Checking packages"

for package in grub efibootmgr os-prober; do
  if ! pacman -Q "$package" >/dev/null 2>&1; then
    echo "Missing package: $package"
    echo "Make sure it is listed in packages.txt and installed."
    exit 1
  fi
done

echo "==> Checking GRUB theme"

if [ ! -f "$THEME_SRC/theme.txt" ]; then
  echo "Missing theme file: $THEME_SRC/theme.txt"
  exit 1
fi

echo "==> Installing GRUB theme"

sudo rm -rf "$THEME_DEST"
sudo mkdir -p "$THEME_DEST"
sudo cp -R "$THEME_SRC"/. "$THEME_DEST"/

echo "==> Updating GRUB defaults"

set_grub_option "GRUB_TIMEOUT" "5"
set_grub_option "GRUB_DISABLE_OS_PROBER" "false"
set_grub_option "GRUB_THEME" "\"$THEME_DEST/theme.txt\""

echo "==> Installing GRUB"

sudo grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=GRUB \
  --removable \
  --modules="tpm" \
  --disable-shim-lock

echo "==> Generating GRUB config"

sudo grub-mkconfig -o /boot/grub/grub.cfg

if command -v sbctl >/dev/null 2>&1; then
  echo "==> Signing GRUB files with sbctl"

  if [ -f /boot/EFI/BOOT/BOOTX64.EFI ]; then
    sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
  fi

  if [ -f /boot/EFI/GRUB/grubx64.efi ]; then
    sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi
  fi

  if [ -f /boot/grub/x86_64-efi/core.efi ]; then
    sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
  fi

  if [ -f /boot/grub/x86_64-efi/grub.efi ]; then
    sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
  fi

  echo "==> Verifying signatures"
  sudo sbctl verify
else
  echo "==> sbctl not found, skipping Secure Boot signing"
fi

echo "==> GRUB configured"
echo "Verify boot state with:"
echo "  mokutil --sb-state"
echo "  sudo sbctl status"
echo "  sudo sbctl verify"
echo "Reboot and test GRUB."
echo "If Secure Boot is enabled, verify it after boot with mokutil and sbctl."
