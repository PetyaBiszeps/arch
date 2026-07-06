#!/usr/bin/env sh

set -eu

if ! command -v zsh >/dev/null 2>&1; then
  echo "Missing zsh. Install packages first."
  exit 1
fi

ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="${SHELL:-}"

echo "==> Setting default shell"

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
  echo "Default shell is already zsh: $ZSH_PATH"
  exit 0
fi

if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
  echo "==> Adding zsh to /etc/shells: $ZSH_PATH"
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

echo "==> Changing default shell to: $ZSH_PATH"
chsh -s "$ZSH_PATH"

echo "==> Default shell changed"
echo "Log out and log back in to apply it."
