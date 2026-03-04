#!/usr/bin/env sh
set -eu

mode="${1:-title}"
fallback_title="No media"
fallback_artist="playerctl idle"
fallback_status="Stopped"
fallback_cover="/usr/share/icons/Adwaita/scalable/mimetypes/audio-x-generic.svg"

sanitize_path() {
    p="$1"
    p="${p#file://}"
    printf "%s" "${p}" | sed 's/%20/ /g'
}

if ! command -v playerctl >/dev/null 2>&1; then
    case "${mode}" in
        title) printf "%s\n" "${fallback_title}" ;;
        artist) printf "%s\n" "${fallback_artist}" ;;
        status) printf "%s\n" "${fallback_status}" ;;
        status_icon) printf "󰐊\n" ;;
        cover) printf "%s\n" "${fallback_cover}" ;;
        *) exit 1 ;;
    esac
    exit 0
fi

status="$(playerctl status 2>/dev/null || printf "Stopped")"
title="$(playerctl metadata xesam:title 2>/dev/null || true)"
artist="$(playerctl metadata xesam:artist 2>/dev/null || true)"
art_url="$(playerctl metadata mpris:artUrl 2>/dev/null || true)"

[ -n "${title}" ] || title="${fallback_title}"
[ -n "${artist}" ] || artist="${fallback_artist}"

cover="${fallback_cover}"
if [ -n "${art_url}" ]; then
    art_path="$(sanitize_path "${art_url}")"
    if [ -f "${art_path}" ]; then
        cover="${art_path}"
    fi
fi

case "${mode}" in
    title)
        printf "%s\n" "${title}"
        ;;
    artist)
        printf "%s\n" "${artist}"
        ;;
    status)
        printf "%s\n" "${status}"
        ;;
    status_icon)
        if [ "${status}" = "Playing" ]; then
            printf "󰏤\n"
        else
            printf "󰐊\n"
        fi
        ;;
    cover)
        printf "%s\n" "${cover}"
        ;;
    *)
        echo "usage: $0 {title|artist|status|status_icon|cover}" >&2
        exit 1
        ;;
esac
