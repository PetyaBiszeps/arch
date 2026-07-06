#!/usr/bin/env sh

set -eu

YAY_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch/yay"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if command_exists yay; then
  echo "yay is already installed: $(command -v yay)"
  exit 0
fi

echo "==> Installing yay build dependencies"
sudo pacman -S --needed --noconfirm git base-devel

echo "==> Cloning yay"
rm -rf "$YAY_DIR"
mkdir -p "$(dirname "$YAY_DIR")"
git clone https://aur.archlinux.org/yay.git "$YAY_DIR"

echo "==> Building yay"
cd "$YAY_DIR"
makepkg -si --noconfirm

echo "==> Cleaning yay build directory"
rm -rf "$YAY_DIR"

echo "==> yay installed"
yay --version
