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

sign_file() {
  file="$1"

  if sudo test -f "$file"; then
    echo "Signing: $file"
    sudo sbctl sign -s "$file"
  else
    echo "Skip missing file: $file"
  fi
}

echo "==> Checking /boot"

if ! findmnt /boot >/dev/null 2>&1; then
  echo "Missing /boot mount. Mount ESP before configuring GRUB."
  exit 1
fi

echo "==> Checking packages"

for package in grub efibootmgr os-prober sbctl mokutil; do
  if ! yay -Q "$package" >/dev/null 2>&1; then
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

echo "==> Checking sbctl status"

sudo sbctl status

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

echo "==> Signing known boot files"

sign_file "/boot/EFI/BOOT/BOOTX64.EFI"
sign_file "/boot/EFI/GRUB/grubx64.efi"
sign_file "/boot/grub/x86_64-efi/core.efi"
sign_file "/boot/grub/x86_64-efi/grub.efi"
sign_file "/boot/EFI/Linux/arch-linux.efi"
sign_file "/boot/vmlinuz-linux"

echo "==> Signing EFI files from /boot/EFI"

sudo find /boot/EFI \
  -type f \
  -iname "*.efi" \
  ! -path "/boot/EFI/Microsoft/*" \
  -print | while IFS= read -r file; do
    sign_file "$file"
  done

echo "==> Verifying signatures"

sudo sbctl verify

echo "==> Current EFI boot entries"

sudo efibootmgr -v

echo "==> GRUB configured"
echo
echo "Reboot and test GRUB."
echo
echo "After boot, verify:"
echo "  mokutil --sb-state"
echo "  sudo sbctl status"
echo "  sudo sbctl verify"
