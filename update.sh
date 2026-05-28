#!/usr/bin/env bash
# Pull latest changes and reload Hyprland
# Usage: ./update.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Pulling latest dotfiles..."
git -C "$DOTFILES_DIR" pull

echo "==> Reloading Hyprland..."
hyprctl reload

echo "Done."
