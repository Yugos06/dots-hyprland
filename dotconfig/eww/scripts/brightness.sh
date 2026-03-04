#!/usr/bin/env sh
set -eu

mode="${1:-get}"
value="${2:-0}"

get_brightness() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl -m 2>/dev/null | awk -F, '{gsub("%", "", $4); print $4}'
        return
    fi

    printf "50\n"
}

set_brightness() {
    v="$1"
    [ "${v}" -ge 1 ] 2>/dev/null || v=1
    [ "${v}" -le 100 ] 2>/dev/null || v=100

    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl set "${v}%" >/dev/null 2>&1 || true
    fi
}

case "${mode}" in
    get)
        get_brightness
        ;;
    set)
        set_brightness "${value}"
        ;;
    *)
        echo "usage: $0 {get|set <1-100>}" >&2
        exit 1
        ;;
esac
