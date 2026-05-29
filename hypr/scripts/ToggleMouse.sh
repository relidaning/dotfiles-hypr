#!/usr/bin/env bash
# Toggle the external mouse and touchpad on/off together

STATE_FILE="/tmp/mouse_disabled"

toggle_devices() {
    local state=$1
    hyprctl keyword "device[logitech-g502-hero-gaming-mouse]:enabled" "$state"
    hyprctl keyword "device[elan06fa:00-04f3:31dd-touchpad]:enabled" "$state"
    hyprctl keyword "device[elan06fa:00-04f3:31dd-mouse]:enabled" "$state"
}

if [ -f "$STATE_FILE" ]; then
    toggle_devices true
    rm "$STATE_FILE"
    notify-send -i input-mouse "Mouse & Touchpad" "Enabled"
else
    toggle_devices false
    touch "$STATE_FILE"
    notify-send -i input-mouse "Mouse & Touchpad" "Disabled"
fi
