#!/usr/bin/env sh
set -eu

# Never kill/restart bars outside an active Wayland session.
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    exit 0
fi

# Keep Waybar as the primary bar for reliability.
if command -v waybar >/dev/null 2>&1; then
    pkill waybar >/dev/null 2>&1 || true
    nohup waybar >/dev/null 2>&1 &
fi

if command -v mako >/dev/null 2>&1; then
    pkill mako >/dev/null 2>&1 || true
    nohup mako >/dev/null 2>&1 &
fi

# Start Quickshell in parallel (dock/panels), without disabling Waybar.
if command -v qs >/dev/null 2>&1; then
    pkill -f "/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 || true
    pkill qs >/dev/null 2>&1 || true
    nohup "${HOME}/.config/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 &
    nohup qs -p "${HOME}/.config/quickshell/end4-lite" >/dev/null 2>&1 &
fi
