#!/usr/bin/env sh

set -eu

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
HOST_NAME="$(uname -n)"
USER_NAME="$(id -un)"

echo "==> Preparing SSH"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_KEY" ]; then
  echo "==> Creating SSH key: $SSH_KEY"
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "$USER_NAME@$HOST_NAME"
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

echo "==> SSH key setup done"
echo
echo "Public key:"
echo "  $SSH_KEY.pub"
echo
echo "To print it:"
echo "  cat $SSH_KEY.pub"
