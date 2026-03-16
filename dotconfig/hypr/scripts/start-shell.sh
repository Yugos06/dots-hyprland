#!/usr/bin/env sh
set -eu

# Never kill/restart bars outside an active Wayland session.
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    exit 0
fi

start_waybar() {
    cfg="$1"
    css="$2"
    log_file="$3"

    if [ -f "${cfg}" ] && [ -f "${css}" ]; then
        nohup waybar -l info -c "${cfg}" -s "${css}" > "${log_file}" 2>&1 &
    else
        nohup waybar -l info > "${log_file}" 2>&1 &
    fi
}

# Keep Waybar as the primary bar for reliability.
if command -v waybar >/dev/null 2>&1; then
    pkill waybar >/dev/null 2>&1 || true

    state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/waybar"
    mkdir -p "${state_dir}"

    start_waybar "${HOME}/.config/waybar/config.jsonc" "${HOME}/.config/waybar/style.css" "${state_dir}/waybar.log"
    sleep 0.6

    if ! pgrep -x waybar >/dev/null 2>&1; then
        start_waybar "${HOME}/.config/waybar/config.minimal.jsonc" "${HOME}/.config/waybar/style.minimal.css" "${state_dir}/waybar-minimal.log"
    fi
fi

if command -v mako >/dev/null 2>&1; then
    pkill mako >/dev/null 2>&1 || true
    nohup mako >/dev/null 2>&1 &
fi

# Optional: use nwg-dock or hypr-dock if enabled.
use_nwg_dock=0
use_hypr_dock=0
external_dock_running=0

if [ -f "${HOME}/.config/hypr/use-nwg-dock" ] && command -v nwg-dock-hyprland >/dev/null 2>&1; then
    use_nwg_dock=1
elif [ -f "${HOME}/.config/hypr/use-hypr-dock" ] && command -v hypr-dock >/dev/null 2>&1; then
    use_hypr_dock=1
fi

qs_runtime="${HOME}/.config/quickshell/end4-lite/runtime"
dock_disable="${qs_runtime}/disable-dock"
mkdir -p "${qs_runtime}"

if [ "${use_nwg_dock}" -eq 1 ]; then
    pkill hypr-dock >/dev/null 2>&1 || true
    pkill -f nwg-dock-hyprland >/dev/null 2>&1 || true

    if [ -x "${HOME}/.config/nwg-dock-hyprland/launch.sh" ]; then
        nohup env GTK_ICON_THEME=Papirus XDG_ICON_THEME=Papirus \
            "${HOME}/.config/nwg-dock-hyprland/launch.sh" >/dev/null 2>&1 &
    else
        nohup env GTK_ICON_THEME=Papirus XDG_ICON_THEME=Papirus \
            nwg-dock-hyprland -d -hd 0 -hl overlay -p bottom -i 28 -a center -mb 3 -ml 3 -mr 3 -mt 0 \
            -c "sh -lc '${HOME}/.config/hypr/scripts/launchers.sh app'" \
            -ico "/usr/share/icons/Papirus/24x24/actions/view-grid.svg" \
            -s "style.css" >/dev/null 2>&1 &
    fi

    sleep 0.4
    if pgrep -f nwg-dock-hyprland >/dev/null 2>&1; then
        external_dock_running=1
    else
        use_nwg_dock=0
    fi
fi

if [ "${external_dock_running}" -eq 0 ] && [ "${use_hypr_dock}" -eq 1 ]; then
    pkill hypr-dock >/dev/null 2>&1 || true
    pkill -f nwg-dock-hyprland >/dev/null 2>&1 || true
    nohup env GTK_ICON_THEME=Papirus XDG_ICON_THEME=Papirus hypr-dock >/dev/null 2>&1 &
    sleep 0.3
    if pgrep -x hypr-dock >/dev/null 2>&1; then
        external_dock_running=1
    fi
fi

if [ "${external_dock_running}" -eq 1 ]; then
    printf "1\n" > "${dock_disable}"
else
    rm -f "${dock_disable}"
    pkill hypr-dock >/dev/null 2>&1 || true
    pkill -f nwg-dock-hyprland >/dev/null 2>&1 || true
fi

# Start Quickshell in parallel (dock/panels), without disabling Waybar.
if command -v qs >/dev/null 2>&1; then
    if [ -x "${HOME}/.config/quickshell/end4-lite/scripts/dock-apps.sh" ]; then
        "${HOME}/.config/quickshell/end4-lite/scripts/dock-apps.sh" refresh >/dev/null 2>&1 || true
    fi
    pkill -f "/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 || true
    pkill qs >/dev/null 2>&1 || true
    nohup "${HOME}/.config/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 &
    nohup qs -p "${HOME}/.config/quickshell/end4-lite" >/dev/null 2>&1 &
fi
