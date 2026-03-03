#!/usr/bin/env sh
set -eu

state_dir="${HOME}/.config/quickshell/end4-lite/runtime"
state_file="${state_dir}/left-settings.state"

mkdir -p "${state_dir}"

# Ensure the shell is running so the panel can react.
if ! pgrep -x qs >/dev/null 2>&1; then
    "${HOME}/.config/hypr/scripts/start-shell.sh" >/dev/null 2>&1 || true
    sleep 0.2
fi

current="0"
if [ -f "${state_file}" ]; then
    current="$(tr -d '[:space:]' < "${state_file}" || echo 0)"
fi

if [ "${current}" = "1" ]; then
    printf "0\n" > "${state_file}"
    hyprctl notify -1 1500 "rgb(66ccff)" "Panneau parametres: OFF" >/dev/null 2>&1 || true
else
    printf "1\n" > "${state_file}"
    hyprctl notify -1 1500 "rgb(66ff99)" "Panneau parametres: ON" >/dev/null 2>&1 || true
fi
