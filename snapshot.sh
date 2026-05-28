#!/usr/bin/env bash
# Save current monitors.conf for this machine into the repo
# Run after configuring monitors with nwg-displays
# Usage: ./snapshot.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINE="$(hostname)"
MACHINE_DIR="$DOTFILES_DIR/machines/$MACHINE"

mkdir -p "$MACHINE_DIR"
cp "$HOME/.config/hypr/monitors.conf" "$MACHINE_DIR/monitors.conf"
echo "Saved monitor profile for: $MACHINE"
echo "  -> machines/$MACHINE/monitors.conf"
echo ""
echo "Commit it:"
echo "  cd ~/dotfiles && git add machines/$MACHINE && git commit -m 'monitors: add $MACHINE profile'"
