#!/usr/bin/env sh

set -eu

ARCH_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGE_FILE="$ARCH_DIR/packages/packages.txt"

if ! command -v yay >/dev/null 2>&1; then
  echo "Missing yay. Run scripts/yay.sh first."
  exit 1
fi

if [ ! -f "$PACKAGE_FILE" ]; then
  echo "Missing package file: $PACKAGE_FILE"
  exit 1
fi

echo "==> Installing packages from $PACKAGE_FILE"

grep -v '^[[:space:]]*#' "$PACKAGE_FILE" |
  grep -v '^[[:space:]]*$' |
  yay -S --needed --noconfirm -
