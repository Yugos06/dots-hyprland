#!/usr/bin/env sh
set -eu

mode="${1:-os}"

os_name() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ -n "${PRETTY_NAME:-}" ]; then
            printf "%s\n" "${PRETTY_NAME}"
            return
        fi
    fi
    uname -s
}

uptime_human() {
    if command -v uptime >/dev/null 2>&1; then
        uptime -p | sed 's/^up //'
    else
        printf "unknown"
    fi
}

case "${mode}" in
    os)
        os_name
        ;;
    wm)
        if [ -n "${XDG_CURRENT_DESKTOP:-}" ]; then
            printf "%s\n" "${XDG_CURRENT_DESKTOP}"
        else
            printf "Hyprland\n"
        fi
        ;;
    uptime)
        uptime_human
        ;;
    *)
        echo "usage: $0 {os|wm|uptime}" >&2
        exit 1
        ;;
esac
