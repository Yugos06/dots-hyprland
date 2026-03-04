#!/usr/bin/env sh
set -eu

config_dir="${HOME}/.config/eww"

if ! command -v eww >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Dashboard" "eww n'est pas installe" >/dev/null 2>&1 || true
    fi
    exit 0
fi

if eww --config "${config_dir}" active-windows 2>/dev/null | grep -q "dashboard"; then
    eww --config "${config_dir}" close dashboard >/dev/null 2>&1 || true
else
    # Always restart daemon before opening to avoid stale DPI/scale state.
    eww --config "${config_dir}" kill >/dev/null 2>&1 || true
    nohup env GDK_SCALE=1 GDK_DPI_SCALE=1 eww daemon --config "${config_dir}" >/dev/null 2>&1 &
    sleep 0.25
    eww --config "${config_dir}" update active_tab="dashboard" >/dev/null 2>&1 || true
    eww --config "${config_dir}" open dashboard >/dev/null 2>&1 || true
fi
