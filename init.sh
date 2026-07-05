#!/usr/bin/env sh

set -eu

ARCH_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing yay"
sh "$ARCH_DIR/scripts/yay.sh"

echo "==> Installing packages"
sh "$ARCH_DIR/scripts/packages.sh"

echo "==> Creating user directories"
sh "$ARCH_DIR/scripts/user-dirs.sh"

echo "==> Checking setup"
sh "$ARCH_DIR/scripts/check.sh"

echo "==> Done"
