#!/usr/bin/env sh
set -eu

eww_toggle="${HOME}/.config/eww/scripts/toggle-dashboard.sh"
qs_toggle="${HOME}/.config/quickshell/end4-lite/scripts/toggle-left-settings.sh"

if command -v eww >/dev/null 2>&1 && [ -x "${eww_toggle}" ]; then
    exec "${eww_toggle}"
fi

if [ -x "${qs_toggle}" ]; then
    exec "${qs_toggle}"
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Dashboard" "Aucun dashboard detecte (eww/quickshell)" >/dev/null 2>&1 || true
fi
