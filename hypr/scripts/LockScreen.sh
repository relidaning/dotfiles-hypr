#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##

# Update weather cache in background (don't block lock screen)
bash "$HOME/.config/hypr/UserScripts/WeatherWrap.sh" >/dev/null 2>&1 &

# Launch hyprlock directly (no hypridle required)
pidof hyprlock || hyprlock

