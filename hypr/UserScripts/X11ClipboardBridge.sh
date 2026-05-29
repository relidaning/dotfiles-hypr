#!/usr/bin/env bash
# Bridge X11 clipboard (XWayland apps like WeChat) to Wayland so cliphist stores it.
# Uses temp files to avoid bash command substitution dropping null bytes from binary data.
# Prefers image/jpeg over image/png because WeChat's PNG is corrupt.

PREFERRED_IMAGE_TYPES="image/jpeg image/webp image/bmp image/png"
TMPFILE="/tmp/x11clip-bridge-data.bin"
prev_hash=""

while true; do
    targets=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null | tr '\0' '\n')

    if echo "$targets" | grep -q "^image/"; then
        mime=""
        for try_mime in $PREFERRED_IMAGE_TYPES; do
            if echo "$targets" | grep -qF "$try_mime"; then
                mime="$try_mime"
                break
            fi
        done
        [[ -z "$mime" ]] && mime=$(echo "$targets" | grep "^image/" | head -1 | tr -d '\r\n')

        xclip -selection clipboard -t "$mime" -o > "$TMPFILE" 2>/dev/null
        hash=$(md5sum "$TMPFILE" 2>/dev/null | cut -d' ' -f1)

        if [[ -s "$TMPFILE" && "$hash" != "$prev_hash" ]]; then
            prev_hash="$hash"
            wl-copy --type "$mime" < "$TMPFILE"
        fi
    fi

    sleep 0.3
done
