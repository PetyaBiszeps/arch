#!/usr/bin/env sh

set -eu

echo "==> Creating XDG user directories"

if ! command -v xdg-user-dirs-update >/dev/null 2>&1; then
  echo "Missing xdg-user-dirs-update. Install xdg-user-dirs first."
  exit 1
fi

xdg-user-dirs-update

echo "==> XDG user directories created"
