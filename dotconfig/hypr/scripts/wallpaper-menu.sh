#!/usr/bin/env sh
set -eu

WALL_DIR="${HOME}/.config/wallpapers"
APPLY="${HOME}/.config/hypr/scripts/wallpaper-apply.sh"
SEARCH_DIRS="${WALL_DIR}
${HOME}/Pictures/Wallpapers
${HOME}/Pictures/wallpapers
${HOME}/Pictures
/usr/share/backgrounds
/usr/share/wallpapers"

mkdir -p "${WALL_DIR}"

list="$(printf "%s\n" "${SEARCH_DIRS}" | while IFS= read -r dir; do
    [ -n "${dir}" ] || continue
    [ -d "${dir}" ] || continue
    find "${dir}" -maxdepth 3 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \)
done | sort -u)"

[ -n "${list}" ] || {
    echo "No wallpapers in configured directories." >&2
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl notify -1 3500 "rgb(ffaa66)" "Aucun fond d'ecran. Ajoute des images dans ~/.config/wallpapers ou ~/Pictures/Wallpapers." >/dev/null 2>&1 || true
    fi
    exit 1
}

if command -v wofi >/dev/null 2>&1; then
    choice="$(printf "%s\n%s\n" "[random]" "${list}" | wofi --dmenu --prompt "Wallpaper")"
    [ -n "${choice}" ] || exit 0
    if [ "${choice}" = "[random]" ]; then
        exec "${APPLY}" random
    fi
    exec "${APPLY}" "${choice}"
fi

exec "${APPLY}" random
