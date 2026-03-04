#!/usr/bin/env sh
set -eu

mode="${1:-hh}"

upper_first() {
    awk '{print toupper(substr($0,1,1)) substr($0,2)}'
}

case "${mode}" in
    hh)
        date +%H
        ;;
    mm)
        date +%M
        ;;
    month)
        (LC_ALL=fr_FR.UTF-8 date +"%B %Y" 2>/dev/null || date +"%B %Y") | upper_first
        ;;
    calendar)
        if command -v cal >/dev/null 2>&1; then
            LC_ALL=fr_FR.UTF-8 cal -m
        else
            date +"%Y-%m"
        fi
        ;;
    *)
        echo "usage: $0 {hh|mm|month|calendar}" >&2
        exit 1
        ;;
esac
