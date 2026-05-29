#!/usr/bin/env bash
# Bootstrap: install missing environment, then link this repo's configs.
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
MACHINE="$(hostname)"

# ─── 0. Dependency check & install ───────────────────────────────────────────
# Tools required by these dotfiles. Each entry is "command:arch-pkg:apt-pkg"
# (use "-" to mark a package as AUR-only or unavailable in that PM).
TOOLS=(
    "hyprland:hyprland:hyprland"
    "hypridle:hypridle:hypridle"
    "hyprlock:hyprlock:hyprlock"
    "waybar:waybar:waybar"
    "rofi:rofi-wayland:rofi"
    "kitty:kitty:kitty"
    "fish:fish:fish"
    "btop:btop:btop"
    "fastfetch:fastfetch:fastfetch"
    "cava:cava:cava"
    "swappy:swappy:swappy"
    "nwg-displays:nwg-displays:nwg-displays"
    "swaync:swaync:swaync"
    "wlogout:wlogout:wlogout"
    "wallust:wallust:-"
)

# AUR-only packages (no pacman equivalent, need paru/yay)
AUR_ONLY=(wallust goimapnotify)

_detect_pm() {
    if   command -v paru   &>/dev/null; then echo "paru"
    elif command -v yay    &>/dev/null; then echo "yay"
    elif command -v pacman &>/dev/null; then echo "pacman"
    elif command -v apt    &>/dev/null; then echo "apt"
    elif command -v dnf    &>/dev/null; then echo "dnf"
    else echo "unknown"; fi
}

_is_aur_only() {
    local cmd="$1"
    for a in "${AUR_ONLY[@]}"; do [[ "$a" == "$cmd" ]] && return 0; done
    return 1
}

missing_cmds=()
for entry in "${TOOLS[@]}"; do
    cmd="${entry%%:*}"
    command -v "$cmd" &>/dev/null || missing_cmds+=("$entry")
done

if [[ ${#missing_cmds[@]} -gt 0 ]]; then
    echo ""
    echo "==> Missing tools: $(IFS=' '; for e in "${missing_cmds[@]}"; do printf '%s ' "${e%%:*}"; done)"
    PM="$(_detect_pm)"

    case "$PM" in
        paru|yay)
            pkgs=()
            for entry in "${missing_cmds[@]}"; do
                cmd="${entry%%:*}"; arch_pkg="${entry#*:}"; arch_pkg="${arch_pkg%%:*}"
                [[ "$arch_pkg" != "-" ]] && pkgs+=("$arch_pkg")
            done
            [[ ${#pkgs[@]} -gt 0 ]] && "$PM" -S --noconfirm "${pkgs[@]}"
            ;;

        pacman)
            pacman_pkgs=(); aur_pkgs=()
            for entry in "${missing_cmds[@]}"; do
                cmd="${entry%%:*}"; arch_pkg="${entry#*:}"; arch_pkg="${arch_pkg%%:*}"
                [[ "$arch_pkg" == "-" ]] && continue
                if _is_aur_only "$cmd"; then aur_pkgs+=("$arch_pkg")
                else pacman_pkgs+=("$arch_pkg"); fi
            done
            [[ ${#pacman_pkgs[@]} -gt 0 ]] && sudo pacman -S --noconfirm "${pacman_pkgs[@]}"
            if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
                echo "  WARNING: AUR packages needed (${aur_pkgs[*]}) — install paru or yay, then re-run."
            fi
            ;;

        apt)
            # On Ubuntu/Debian, hyprland + its stack is best installed via JaKooLit's script.
            needs_jakoolit=false
            for entry in "${missing_cmds[@]}"; do
                [[ "${entry%%:*}" == "hyprland" ]] && needs_jakoolit=true && break
            done

            if $needs_jakoolit; then
                echo ""
                echo "  Hyprland is not installed. On Ubuntu/Debian the recommended way is"
                echo "  JaKooLit's installer, which sets up the full Hyprland stack:"
                echo "    https://github.com/JaKooLit/Ubuntu-Hyprland"
                echo ""
                read -r -p "  Run JaKooLit's installer now? [y/N] " yn
                if [[ "$yn" =~ ^[Yy]$ ]]; then
                    bash <(curl -s https://raw.githubusercontent.com/JaKooLit/Ubuntu-Hyprland/main/install.sh)
                else
                    echo "  Skipping installer. Re-run ./setup.sh after Hyprland is installed."
                    exit 1
                fi
            else
                sudo apt-get update -qq
                for entry in "${missing_cmds[@]}"; do
                    cmd="${entry%%:*}"; apt_pkg="${entry##*:}"
                    if [[ "$apt_pkg" == "-" ]]; then
                        echo "  WARNING: $cmd has no apt package — install it manually."
                    else
                        echo "  Installing $apt_pkg..."
                        sudo apt-get install -y "$apt_pkg" || echo "  WARNING: $apt_pkg not found in apt."
                    fi
                done
            fi
            ;;

        dnf)
            for entry in "${missing_cmds[@]}"; do
                cmd="${entry%%:*}"
                echo "  Installing $cmd via dnf..."
                sudo dnf install -y "$cmd" || echo "  WARNING: $cmd not found via dnf."
            done
            ;;

        *)
            echo "  ERROR: Unknown package manager. Install missing tools manually and re-run."
            exit 1
            ;;
    esac
    echo ""
fi
# ─────────────────────────────────────────────────────────────────────────────

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

# swaync
backup_and_link "$DOTFILES_DIR/swaync"       "$HOME/.config/swaync"

# Hyprland-adjacent tools
backup_and_link "$DOTFILES_DIR/wlogout"      "$HOME/.config/wlogout"
backup_and_link "$DOTFILES_DIR/ags"          "$HOME/.config/ags"
backup_and_link "$DOTFILES_DIR/swappy"       "$HOME/.config/swappy"
backup_and_link "$DOTFILES_DIR/nwg-displays" "$HOME/.config/nwg-displays"
backup_and_link "$DOTFILES_DIR/cava"         "$HOME/.config/cava"
backup_and_link "$DOTFILES_DIR/quickshell"   "$HOME/.config/quickshell"

# Terminal, shell, and theming
backup_and_link "$DOTFILES_DIR/wallust"      "$HOME/.config/wallust"
backup_and_link "$DOTFILES_DIR/kitty"        "$HOME/.config/kitty"
backup_and_link "$DOTFILES_DIR/fish"         "$HOME/.config/fish"
backup_and_link "$DOTFILES_DIR/fastfetch"    "$HOME/.config/fastfetch"
backup_and_link "$DOTFILES_DIR/btop"         "$HOME/.config/btop"

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
