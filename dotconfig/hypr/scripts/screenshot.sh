#!/usr/bin/env sh
set -eu

mode="${1:-area-copy}"
out_dir="${HOME}/Pictures/Screenshots"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
out_file="${out_dir}/shot_${timestamp}.png"

mkdir -p "${out_dir}"

if command -v grimblast >/dev/null 2>&1; then
    case "${mode}" in
        area-copy) exec grimblast copy area ;;
        area-save) exec grimblast save area "${out_file}" ;;
        screen-copy) exec grimblast copy screen ;;
        screen-save) exec grimblast save screen "${out_file}" ;;
        window-copy) exec grimblast copy active ;;
        window-save) exec grimblast save active "${out_file}" ;;
        *)
            echo "usage: $0 {area-copy|area-save|screen-copy|screen-save|window-copy|window-save}" >&2
            exit 1
            ;;
    esac
fi

# Fallback path without grimblast.
if ! command -v grim >/dev/null 2>&1; then
    echo "grimblast or grim is required for screenshots" >&2
    exit 1
fi

case "${mode}" in
    area-copy)
        if command -v slurp >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
            exec sh -c 'grim -g "$(slurp)" - | wl-copy'
        fi
        ;;
    area-save)
        if command -v slurp >/dev/null 2>&1; then
            exec sh -c "grim -g \"\$(slurp)\" \"${out_file}\""
        fi
        ;;
    screen-copy)
        if command -v wl-copy >/dev/null 2>&1; then
            exec sh -c 'grim - | wl-copy'
        fi
        ;;
    screen-save)
        exec grim "${out_file}"
        ;;
    *)
        echo "mode ${mode} requires grimblast" >&2
        exit 1
        ;;
esac

echo "missing fallback dependencies (slurp/wl-copy) for mode: ${mode}" >&2
exit 1
