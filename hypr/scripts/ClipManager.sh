#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   or   ALT DEL - cliphist wipe (all)'
# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents

# Thumbnail cache dir (persists across opens, cleared on reboot)
thumbdir="/tmp/cliphist-thumbs"
mkdir -p "$thumbdir"

# Generate rofi entries: images get an inline thumbnail icon
generate_entries() {
    while IFS= read -r line; do
        if echo "$line" | grep -q "binary data"; then
            id=$(echo "$line" | awk '{print $1}')
            thumb="$thumbdir/${id}.png"
            if [[ ! -f "$thumb" ]]; then
                cliphist decode <<<"$line" | convert - -thumbnail 80x80^ -gravity center -extent 80x80 "$thumb" 2>/dev/null \
                    || cliphist decode <<<"$line" | python3 -c "
import sys, io
from PIL import Image
data = sys.stdin.buffer.read()
img = Image.open(io.BytesIO(data))
img.thumbnail((80, 80))
bg = Image.new('RGB', (80, 80), (30, 30, 30))
off = ((80 - img.width) // 2, (80 - img.height) // 2)
bg.paste(img, off)
bg.save(sys.argv[1])
" "$thumb" 2>/dev/null
            fi
            printf '%s\0icon\x1f%s\n' "$line" "$thumb"
        else
            echo "$line"
        fi
    done < <(cliphist list)
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

while true; do
    result=$(
        rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config $rofi_theme \
            -show-icons \
            -mesg "$msg" \
            < <(generate_entries)
    )

    case "$?" in
        1)
            exit
            ;;
        0)
            case "$result" in
                "")
                    continue
                    ;;
                *)
                    cliphist decode <<<"$result" | wl-copy
                    exit
                    ;;
            esac
            ;;
        10)
            cliphist delete <<<"$result"
            ;;
        11)
            cliphist wipe
            ;;
    esac
done

