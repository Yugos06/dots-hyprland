#!/usr/bin/env sh
set -eu

mode="${1:-get}"
value="${2:-0}"

get_volume() {
    if command -v pamixer >/dev/null 2>&1; then
        pamixer --get-volume 2>/dev/null || printf "0\n"
        return
    fi

    if command -v wpctl >/dev/null 2>&1; then
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d\n", $2 * 100}'
        return
    fi

    printf "0\n"
}

set_volume() {
    v="$1"
    [ "${v}" -ge 0 ] 2>/dev/null || v=0
    [ "${v}" -le 100 ] 2>/dev/null || v=100

    if command -v pamixer >/dev/null 2>&1; then
        pamixer --set-volume "${v}" >/dev/null 2>&1 || true
        exit 0
    fi

    if command -v wpctl >/dev/null 2>&1; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$((v))%" >/dev/null 2>&1 || true
        exit 0
    fi
}

case "${mode}" in
    get)
        get_volume
        ;;
    set)
        set_volume "${value}"
        ;;
    *)
        echo "usage: $0 {get|set <0-100>}" >&2
        exit 1
        ;;
esac
