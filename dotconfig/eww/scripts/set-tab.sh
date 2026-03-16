#!/usr/bin/env sh
set -eu

tab="${1:-dashboard}"
config_dir="${HOME}/.config/eww"

case "${tab}" in
    dashboard|media|performance|weather|ai) ;;
    *)
        echo "invalid tab: ${tab}" >&2
        exit 1
        ;;
esac

if ! command -v eww >/dev/null 2>&1; then
    exit 0
fi

if ! pgrep -x eww >/dev/null 2>&1; then
    nohup env GDK_SCALE=1 GDK_DPI_SCALE=1 eww daemon --config "${config_dir}" >/dev/null 2>&1 &
    sleep 0.2
fi

eww --config "${config_dir}" update active_tab="${tab}" >/dev/null 2>&1 || true

if ! eww --config "${config_dir}" active-windows 2>/dev/null | grep -q "dashboard"; then
    eww --config "${config_dir}" open dashboard >/dev/null 2>&1 || true
fi
