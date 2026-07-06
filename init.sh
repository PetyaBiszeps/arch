#!/usr/bin/env sh

set -eu

ARCH_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing yay"
sh "$ARCH_DIR/scripts/yay.sh"

echo "==> Installing packages"
sh "$ARCH_DIR/scripts/packages.sh"

echo "==> Creating user directories"
sh "$ARCH_DIR/scripts/user-dirs.sh"

echo "==> Enabling services"
sh "$ARCH_DIR/scripts/services.sh"

echo "==> Configuring Ly"
sh "$ARCH_DIR/scripts/ly.sh"

echo "==> Configuring bootloader"
sh "$ARCH_DIR/scripts/bootloader.sh"

echo "==> Setting default shell"
sh "$ARCH_DIR/scripts/shell.sh"

echo "==> Preparing SSH / GitHub access"
sh "$ARCH_DIR/scripts/ssh.sh"

echo "==> Applying dotfiles"
sh "$ARCH_DIR/scripts/dotfiles.sh"

echo "==> Checking setup"
sh "$ARCH_DIR/scripts/check.sh"

echo "==> Done"
