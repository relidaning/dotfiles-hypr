#!/bin/bash
# Warp cursor to center of newly focused window when focus changes via keyboard.
# Skips the warp if the cursor is already inside the focused window (mouse-driven focus).

SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

nc -U "$SOCK" | while IFS= read -r line; do
    [[ "${line%%>>*}" != "activewindow" ]] && continue

    win=$(hyprctl activewindow -j 2>/dev/null) || continue
    cur=$(hyprctl cursorpos -j 2>/dev/null) || continue

    result=$(jq -n \
        --argjson win "$win" \
        --argjson cur "$cur" \
        '{
            inside: ($cur.x >= $win.at[0] and $cur.x <= ($win.at[0] + $win.size[0]) and
                     $cur.y >= $win.at[1] and $cur.y <= ($win.at[1] + $win.size[1])),
            cx: ($win.at[0] + $win.size[0] / 2 | floor),
            cy: ($win.at[1] + $win.size[1] / 2 | floor)
        }' 2>/dev/null) || continue

    [[ "$(jq -r '.inside' <<<"$result")" == "true" ]] && continue

    hyprctl dispatch movecursor \
        "$(jq -r '.cx' <<<"$result")" \
        "$(jq -r '.cy' <<<"$result")" >/dev/null 2>&1
done
