#!/usr/bin/env sh

set -eu

DOTFILES_REPO="git@github.com:PetyaBiszeps/dotfiles.git"
PROJECTS_DIR="$HOME/Documents/dev/os"
DOTFILES_DIR="$PROJECTS_DIR/dotfiles"

echo "==> Preparing projects directory"
mkdir -p "$PROJECTS_DIR"

if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "==> Updating dotfiles"
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo "==> Cloning dotfiles"
  rm -rf "$DOTFILES_DIR"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo "==> Running dotfiles init"
sh "$DOTFILES_DIR/init.sh"

echo "==> Dotfiles applied"
