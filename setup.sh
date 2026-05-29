#!/usr/bin/env bash
# Bootstrap: link this repo's configs into ~/.config/hypr, ~/.config/waybar, ~/.config/rofi
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
MACHINE="$(hostname)"

echo "==> Setting up Hyprland dotfiles for: $MACHINE"

mkdir -p "$HYPR_DIR"

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

# Hyprland core configs
backup_and_link "$DOTFILES_DIR/hypr/hyprland.conf"        "$HYPR_DIR/hyprland.conf"
backup_and_link "$DOTFILES_DIR/hypr/hypridle.conf"        "$HYPR_DIR/hypridle.conf"
backup_and_link "$DOTFILES_DIR/hypr/hyprlock.conf"        "$HYPR_DIR/hyprlock.conf"
backup_and_link "$DOTFILES_DIR/hypr/hyprlock-2k.conf"     "$HYPR_DIR/hyprlock-2k.conf"
backup_and_link "$DOTFILES_DIR/hypr/application-style.conf" "$HYPR_DIR/application-style.conf"
backup_and_link "$DOTFILES_DIR/hypr/configs"              "$HYPR_DIR/configs"
backup_and_link "$DOTFILES_DIR/hypr/animations"           "$HYPR_DIR/animations"
backup_and_link "$DOTFILES_DIR/hypr/scripts"              "$HYPR_DIR/scripts"
backup_and_link "$DOTFILES_DIR/hypr/wallpaper_effects"    "$HYPR_DIR/wallpaper_effects"
backup_and_link "$DOTFILES_DIR/hypr/wallust"              "$HYPR_DIR/wallust"

# Shared hypr configs
backup_and_link "$DOTFILES_DIR/hypr/UserConfigs"          "$HYPR_DIR/UserConfigs"
backup_and_link "$DOTFILES_DIR/hypr/UserScripts"          "$HYPR_DIR/UserScripts"
backup_and_link "$DOTFILES_DIR/hypr/Monitor_Profiles"     "$HYPR_DIR/Monitor_Profiles"
backup_and_link "$DOTFILES_DIR/hypr/workspaces.conf"      "$HYPR_DIR/workspaces.conf"

# Machine-specific monitor config (symlinked so changes stay tracked in git)
MACHINE_MONITORS="$DOTFILES_DIR/machines/$MACHINE/monitors.conf"
if [[ -f "$MACHINE_MONITORS" ]]; then
    echo "  Linking monitor profile for: $MACHINE"
    backup_and_link "$MACHINE_MONITORS" "$HYPR_DIR/monitors.conf"
else
    echo ""
    echo "NOTE: No monitor profile found for '$MACHINE'."
    echo "Run nwg-displays to configure monitors, then save it:"
    echo "  ./snapshot.sh"
fi

# Waybar and rofi (whole dirs)
backup_and_link "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"
backup_and_link "$DOTFILES_DIR/rofi"   "$HOME/.config/rofi"

# goimapnotify
IMAP_CONF_SRC="$DOTFILES_DIR/goimapnotify/config.json"
IMAP_CONF_DST="$HOME/.config/imapnotify/imapnotify.json"
if [[ ! -f "$IMAP_CONF_SRC" ]]; then
    echo "  Copying goimapnotify example config — fill in credentials at: $IMAP_CONF_SRC"
    cp "$DOTFILES_DIR/goimapnotify/config.example.json" "$IMAP_CONF_SRC"
fi
mkdir -p "$HOME/.config/imapnotify"
backup_and_link "$IMAP_CONF_SRC" "$IMAP_CONF_DST"

echo ""
echo "Done. Reload Hyprland (SUPER + SHIFT + R) or re-login."
