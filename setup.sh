#!/usr/bin/env bash
# Bootstrap: link this repo's configs into ~/.config/hypr
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
MACHINE="$(hostname)"

echo "==> Setting up Hyprland dotfiles for: $MACHINE"

# Check that JaKooLit Hyprland config is already installed
if [[ ! -f "$HYPR_DIR/hyprland.conf" ]]; then
    echo ""
    echo "ERROR: $HYPR_DIR/hyprland.conf not found."
    echo "Install JaKooLit's Hyprland config first:"
    echo "  https://github.com/JaKooLit/Ubuntu-Hyprland"
    echo "Then re-run this script."
    exit 1
fi

backup_and_link() {
    local src="$1"
    local dst="$2"

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "  Backing up $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    if [[ -L "$dst" ]]; then
        rm "$dst"
    fi

    echo "  Linking $dst"
    ln -s "$src" "$dst"
}

# Link UserConfigs, UserScripts, Monitor_Profiles, workspaces.conf
backup_and_link "$DOTFILES_DIR/hypr/UserConfigs"      "$HYPR_DIR/UserConfigs"
backup_and_link "$DOTFILES_DIR/hypr/UserScripts"      "$HYPR_DIR/UserScripts"
backup_and_link "$DOTFILES_DIR/hypr/Monitor_Profiles" "$HYPR_DIR/Monitor_Profiles"
backup_and_link "$DOTFILES_DIR/hypr/workspaces.conf"  "$HYPR_DIR/workspaces.conf"

# Apply machine-specific monitor config
MACHINE_MONITORS="$DOTFILES_DIR/machines/$MACHINE/monitors.conf"
if [[ -f "$MACHINE_MONITORS" ]]; then
    echo "  Applying monitor profile for: $MACHINE"
    cp "$MACHINE_MONITORS" "$HYPR_DIR/monitors.conf"
else
    echo ""
    echo "NOTE: No monitor profile found for '$MACHINE'."
    echo "Run nwg-displays to configure monitors, then save it:"
    echo "  ./snapshot.sh"
fi

echo ""
echo "Done. Reload Hyprland (SUPER + SHIFT + R) or re-login."
