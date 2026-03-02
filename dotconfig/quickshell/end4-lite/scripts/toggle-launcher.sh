#!/usr/bin/env sh
set -eu

if ! command -v wofi >/dev/null 2>&1; then
    echo "wofi not installed"
    exit 1
fi

pick="$(printf "%s\n" \
    "Apps" \
    "Terminal" \
    "Fichiers" \
    "Navigateur" \
    "Capture ecran" \
    "Theme menu" \
    "Verrouiller" \
    "Eteindre" | wofi --dmenu --prompt "Launcher")"

case "${pick:-}" in
    "Apps")
        exec wofi --show drun
        ;;
    "Terminal")
        exec hyprctl dispatch exec kitty
        ;;
    "Fichiers")
        exec hyprctl dispatch exec thunar
        ;;
    "Navigateur")
        exec hyprctl dispatch exec firefox
        ;;
    "Capture ecran")
        exec hyprctl dispatch exec grimblast copy area
        ;;
    "Theme menu")
        exec "${HOME}/.config/hypr/scripts/theme-switch.sh" menu
        ;;
    "Verrouiller")
        exec hyprctl dispatch exec hyprlock
        ;;
    "Eteindre")
        exec hyprctl dispatch exit
        ;;
    *)
        exit 0
        ;;
esac
