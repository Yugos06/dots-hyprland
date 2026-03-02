#!/usr/bin/env sh
set -eu

# Prefer Quickshell. Fall back to Waybar + Mako if unavailable.
if command -v qs >/dev/null 2>&1; then
    pkill waybar >/dev/null 2>&1 || true
    pkill mako >/dev/null 2>&1 || true
    pkill -f "/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 || true
    pkill qs >/dev/null 2>&1 || true
    nohup "${HOME}/.config/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 &
    nohup qs -p "${HOME}/.config/quickshell/end4-lite" >/dev/null 2>&1 &
    exit 0
fi

if command -v waybar >/dev/null 2>&1; then
    nohup waybar >/dev/null 2>&1 &
fi

if command -v mako >/dev/null 2>&1; then
    nohup mako >/dev/null 2>&1 &
fi
