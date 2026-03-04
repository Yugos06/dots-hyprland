#!/usr/bin/env sh
set -eu

mode="${1:-temp}"
cache_file="/tmp/eww-weather.cache"
stamp_file="/tmp/eww-weather.stamp"
ttl=900

fetch_weather() {
    line=""
    if command -v curl >/dev/null 2>&1; then
        line="$(curl -fsS --max-time 5 "https://wttr.in/?format=%t|%C|%c|%h|%w" 2>/dev/null || true)"
    fi

    if [ -z "${line}" ]; then
        line="--|No weather data|󰖐|--|--"
    fi

    printf "%s\n" "${line}" > "${cache_file}"
    date +%s > "${stamp_file}"
}

ensure_cache() {
    now="$(date +%s)"
    last=0

    if [ -f "${stamp_file}" ]; then
        last="$(cat "${stamp_file}" 2>/dev/null || printf "0")"
    fi

    if [ ! -s "${cache_file}" ] || [ $((now - last)) -ge "${ttl}" ]; then
        fetch_weather
    fi
}

ensure_cache

raw="$(cat "${cache_file}" 2>/dev/null || printf "--|No weather data|󰖐|--|--")"
IFS='|' read -r temp desc icon humidity wind <<EOF2
${raw}
EOF2

case "${mode}" in
    temp)
        printf "%s\n" "${temp}"
        ;;
    desc)
        printf "%s\n" "${desc}"
        ;;
    icon)
        printf "%s\n" "${icon}"
        ;;
    detail)
        printf "Humidity %s   Wind %s\n" "${humidity}" "${wind}"
        ;;
    *)
        echo "usage: $0 {temp|desc|icon|detail}" >&2
        exit 1
        ;;
esac
