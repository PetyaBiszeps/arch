#!/usr/bin/env sh

set -eu

ARCH_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGE_FILE="$ARCH_DIR/packages/packages.txt"

OK_COUNT=0
WARN_COUNT=0

ok() {
  OK_COUNT=$((OK_COUNT + 1))
  printf '[OK]   %s\n' "$1"
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  printf '[WARN] %s\n' "$1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_command() {
  name="$1"

  if command_exists "$name"; then
    ok "command found: $name"
  else
    warn "command missing: $name"
  fi
}

check_package_file() {
  if [ -f "$PACKAGE_FILE" ]; then
    ok "package file exists: $PACKAGE_FILE"
  else
    warn "package file missing: $PACKAGE_FILE"
  fi
}

check_user_dir() {
  dir="$1"

  if [ -d "$HOME/$dir" ]; then
    ok "user directory exists: ~/$dir"
  else
    warn "user directory missing: ~/$dir"
  fi
}

check_script_syntax() {
  file="$1"

  if [ ! -f "$file" ]; then
    warn "script missing: $file"
    return 0
  fi

  if sh -n "$file" 2>/dev/null; then
    ok "shell syntax ok: $file"
  else
    warn "shell syntax failed: $file"
  fi
}

echo "==> Arch setup check"
echo

echo "==> Scripts"
check_script_syntax "$ARCH_DIR/init.sh"
check_script_syntax "$ARCH_DIR/scripts/yay.sh"
check_script_syntax "$ARCH_DIR/scripts/packages.sh"
check_script_syntax "$ARCH_DIR/scripts/user-dirs.sh"
check_script_syntax "$ARCH_DIR/scripts/check.sh"

echo
echo "==> Package source"
check_package_file

echo
echo "==> Core commands"
check_command yay
check_command git
check_command zsh
check_command niri
check_command ghostty
check_command nvim

echo
echo "==> XDG user directories"
check_user_dir "Desktop"
check_user_dir "Documents"
check_user_dir "Downloads"
check_user_dir "Music"
check_user_dir "Pictures"
check_user_dir "Public"
check_user_dir "Templates"
check_user_dir "Videos"

echo
echo "==> Summary"
echo "OK:   $OK_COUNT"
echo "WARN: $WARN_COUNT"

exit 0
