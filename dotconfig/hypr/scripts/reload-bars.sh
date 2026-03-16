#!/usr/bin/env sh
set -eu

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

if [ -x "${HOME}/.config/hypr/scripts/start-shell.sh" ]; then
    exec "${HOME}/.config/hypr/scripts/start-shell.sh"
fi
