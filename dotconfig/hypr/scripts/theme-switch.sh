#!/usr/bin/env sh
set -eu

THEMES_DIR="${HOME}/.config/themes"
HYPR_THEME_OUT="${HOME}/.config/hypr/conf/95-theme-auto.conf"
WAYBAR_STYLE_OUT="${HOME}/.config/waybar/style.css"
WOFI_STYLE_OUT="${HOME}/.config/wofi/style.css"
MAKO_OUT="${HOME}/.config/mako/config"
CURRENT_FILE="${THEMES_DIR}/current.theme"
WALL="${HOME}/.config/wallpapers/current"
QS_THEME_BRIDGE="${HOME}/.config/quickshell/end4-lite/services/ThemeBridge.qml"
QS_PATH="${HOME}/.config/quickshell/end4-lite"

choose_theme() {
    if command -v wofi >/dev/null 2>&1; then
        printf "%s\n" "catppuccin" "dark" "light" | wofi --dmenu --prompt "Theme"
    else
        printf "%s\n" "catppuccin"
    fi
}

apply_mako() {
    theme_mako="$1"
    cat > "${MAKO_OUT}" <<'EOF'
sort=-time
layer=overlay
anchor=top-left
padding=14
width=360
height=180
margin=12
border-size=1
border-radius=14
icons=1
max-icon-size=48
default-timeout=4500
ignore-timeout=1
font=JetBrainsMono Nerd Font 11
EOF
    cat "${theme_mako}" >> "${MAKO_OUT}"
}

apply_quickshell_theme() {
    [ -f "${QS_THEME_BRIDGE}" ] || return 0
    tmp="${QS_THEME_BRIDGE}.tmp"
    sed "s/^    property string current: \".*\"/    property string current: \"${theme}\"/" "${QS_THEME_BRIDGE}" > "${tmp}"
    mv "${tmp}" "${QS_THEME_BRIDGE}"
}

theme="${1:-}"

if [ "${theme}" = "menu" ] || [ -z "${theme}" ]; then
    theme="$(choose_theme || true)"
fi

[ -n "${theme}" ] || exit 0

case "${theme}" in
    catppuccin|dark|light) ;;
    *)
        echo "Theme invalide: ${theme}" >&2
        exit 1
        ;;
esac

THEME_PATH="${THEMES_DIR}/${theme}"
[ -d "${THEME_PATH}" ] || {
    echo "Theme introuvable: ${THEME_PATH}" >&2
    exit 1
}

cp "${THEME_PATH}/hypr.conf" "${HYPR_THEME_OUT}"
cp "${THEME_PATH}/waybar.css" "${WAYBAR_STYLE_OUT}"
cp "${THEME_PATH}/wofi.css" "${WOFI_STYLE_OUT}"
apply_mako "${THEME_PATH}/mako.conf"
apply_quickshell_theme
printf "%s\n" "${theme}" > "${CURRENT_FILE}"

# Visual transition between themes (if wallpaper exists).
if command -v swww >/dev/null 2>&1 && [ -f "${WALL}" ]; then
    swww img "${WALL}" --transition-type wipe --transition-angle 30 --transition-step 90 --transition-duration 1 >/dev/null 2>&1 || true
fi

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

if command -v pgrep >/dev/null 2>&1 && pgrep -x qs >/dev/null 2>&1; then
    pkill qs >/dev/null 2>&1 || true
    pkill -f "/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 || true
    if command -v qs >/dev/null 2>&1; then
        nohup "${HOME}/.config/quickshell/end4-lite/scripts/status-daemon.sh" >/dev/null 2>&1 &
        nohup qs -p "${QS_PATH}" >/dev/null 2>&1 &
    fi
else
    if command -v pkill >/dev/null 2>&1; then
        pkill waybar >/dev/null 2>&1 || true
        pkill mako >/dev/null 2>&1 || true
    fi

    if command -v waybar >/dev/null 2>&1; then
        nohup waybar >/dev/null 2>&1 &
    fi

    if command -v mako >/dev/null 2>&1; then
        nohup mako >/dev/null 2>&1 &
    fi
fi
