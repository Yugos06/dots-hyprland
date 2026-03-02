#!/usr/bin/env sh
set -eu

if ! command -v wofi >/dev/null 2>&1; then
    echo "wofi not installed"
    exit 1
fi

pick="$(printf "%s\n" \
    "󰆍  Terminal" \
    "󰉋  Fichiers" \
    "󰖟  Navigateur" \
    "󰄄  Capture zone (copier)" \
    "󰄀  Capture ecran (copier)" \
    "󰄅  Capture zone (fichier)" \
    "󰘳  Theme menu" \
    "󰌾  Verrouiller" \
    "󰐥  Eteindre" | wofi --dmenu --prompt "Actions" --allow-images --allow-markup)"

case "${pick:-}" in
    "󰆍  Terminal")
        exec hyprctl dispatch exec kitty
        ;;
    "󰉋  Fichiers")
        exec hyprctl dispatch exec thunar
        ;;
    "󰖟  Navigateur")
        exec hyprctl dispatch exec firefox
        ;;
    "󰄄  Capture zone (copier)")
        exec hyprctl dispatch exec ~/.config/hypr/scripts/screenshot.sh area-copy
        ;;
    "󰄀  Capture ecran (copier)")
        exec hyprctl dispatch exec ~/.config/hypr/scripts/screenshot.sh screen-copy
        ;;
    "󰄅  Capture zone (fichier)")
        exec hyprctl dispatch exec ~/.config/hypr/scripts/screenshot.sh area-save
        ;;
    "󰘳  Theme menu")
        exec "${HOME}/.config/hypr/scripts/theme-switch.sh" menu
        ;;
    "󰌾  Verrouiller")
        exec hyprctl dispatch exec hyprlock
        ;;
    "󰐥  Eteindre")
        exec hyprctl dispatch exit
        ;;
    *)
        exit 0
        ;;
esac
