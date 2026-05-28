# Hyprland Dotfiles

Personal [JaKooLit Hyprland](https://github.com/JaKooLit/Ubuntu-Hyprland) config.

## What's tracked

| Path | Purpose |
|------|---------|
| `hypr/UserConfigs/` | Keybinds, settings, window rules, startup apps |
| `hypr/UserScripts/` | Custom scripts |
| `hypr/Monitor_Profiles/` | Named monitor layouts (selectable via rofi) |
| `hypr/workspaces.conf` | Workspace rules |
| `machines/<hostname>/monitors.conf` | Per-machine monitor config |

## Apply to a new machine

1. Install JaKooLit's base config:
   ```bash
   # Ubuntu/Debian
   bash <(curl -s https://raw.githubusercontent.com/JaKooLit/Ubuntu-Hyprland/main/install.sh)
   ```

2. Clone and run setup:
   ```bash
   git clone https://github.com/relidaning/dotfiles-hypr ~/dotfiles
   cd ~/dotfiles
   chmod +x setup.sh update.sh snapshot.sh
   ./setup.sh
   ```

3. If this is a new machine with no saved monitor profile, configure monitors with `nwg-displays`, then save it:
   ```bash
   ./snapshot.sh
   git add machines/$(hostname) && git commit -m "monitors: add $(hostname) profile"
   git push
   ```

## Update (after pulling changes)

```bash
cd ~/dotfiles && ./update.sh
```

## Save monitor layout changes

After adjusting monitors with `nwg-displays`:
```bash
cd ~/dotfiles && ./snapshot.sh
```

## Workflow: editing configs

Since `~/.config/hypr/UserConfigs` is symlinked to `~/dotfiles/hypr/UserConfigs`, edits there are live in the repo. Just commit and push when happy:

```bash
cd ~/dotfiles
git add -p
git commit -m "describe what you changed"
git push
```
