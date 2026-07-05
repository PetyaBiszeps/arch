#!/usr/bin/env sh

set -eu

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
SSH_KEY_TITLE="$(hostname)-arch"

echo "==> Preparing SSH"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_KEY" ]; then
  echo "==> Creating SSH key: $SSH_KEY"
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "$(whoami)@$(hostname)"
else
  echo "SSH key already exists: $SSH_KEY"
fi

if [ ! -f "$SSH_KEY.pub" ]; then
  echo "Missing SSH public key: $SSH_KEY.pub"
  exit 1
fi

echo "==> Adding github.com to known_hosts"
touch "$SSH_DIR/known_hosts"
chmod 600 "$SSH_DIR/known_hosts"

if ! ssh-keygen -F github.com -f "$SSH_DIR/known_hosts" >/dev/null 2>&1; then
  ssh-keyscan github.com >> "$SSH_DIR/known_hosts" 2>/dev/null
else
  echo "github.com is already in known_hosts"
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing gh. Make sure github-cli is installed."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "==> GitHub authentication"
  gh auth login
else
  echo "GitHub CLI is already authenticated"
fi

echo "==> Adding SSH key to GitHub"

if gh ssh-key list | grep "$SSH_KEY_TITLE" >/dev/null 2>&1; then
  echo "GitHub SSH key already exists with title: $SSH_KEY_TITLE"
else
  gh ssh-key add "$SSH_KEY.pub" --title "$SSH_KEY_TITLE"
fi

echo "==> SSH setup done"
echo
echo "You can test manually with:"
echo "  ssh -T git@github.com"
