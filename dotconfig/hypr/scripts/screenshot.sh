#!/usr/bin/env sh
set -eu

mode="${1:-area-copy}"
if command -v xdg-user-dir >/dev/null 2>&1; then
    pictures_dir="$(xdg-user-dir PICTURES 2>/dev/null || true)"
else
    pictures_dir=""
fi
[ -n "${pictures_dir}" ] || pictures_dir="${HOME}/Pictures"
out_dir="${pictures_dir}/screenshot"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
out_file="${out_dir}/shot_${timestamp}.png"
last_file="${out_dir}/latest.png"

mkdir -p "${out_dir}"

if [ "${mode}" = "open-dir" ]; then
    exec xdg-open "${out_dir}"
fi

if ! command -v grim >/dev/null 2>&1 && ! command -v grimblast >/dev/null 2>&1; then
    echo "grim or grimblast is required for screenshots" >&2
    exit 1
fi

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Screenshot" "$1" >/dev/null 2>&1 || true
    fi
}

copy_file_clipboard() {
    if ! command -v wl-copy >/dev/null 2>&1; then
        return 1
    fi
    wl-copy < "$1"
}

capture_area() {
    if ! command -v slurp >/dev/null 2>&1; then
        echo "slurp is required for area captures" >&2
        return 1
    fi
    grim -g "$(slurp)" "$1"
}

capture_screen() {
    grim "$1"
}

capture_window() {
    if ! command -v hyprctl >/dev/null 2>&1; then
        echo "hyprctl is required for window captures" >&2
        return 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is required for window captures" >&2
        return 1
    fi

    geo="$(hyprctl activewindow -j 2>/dev/null | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null || true)"
    if [ -z "${geo}" ] || [ "${geo}" = "null,null nullxnull" ]; then
        echo "unable to read active window geometry" >&2
        return 1
    fi

    grim -g "${geo}" "$1"
}

save_and_announce() {
    cp "$1" "$last_file"
}

case "${mode}" in
    area-copy)
        if capture_area "${out_file}" && copy_file_clipboard "${out_file}"; then
            save_and_announce "${out_file}"
            notify "Area copied + saved: ${out_file}"
            exit 0
        fi
        ;;
    area-save)
        if capture_area "${out_file}"; then
            save_and_announce "${out_file}"
            notify "Area saved: ${out_file}"
            exit 0
        fi
        ;;
    screen-copy)
        if capture_screen "${out_file}" && copy_file_clipboard "${out_file}"; then
            save_and_announce "${out_file}"
            notify "Screen copied + saved: ${out_file}"
            exit 0
        fi
        ;;
    screen-save)
        if capture_screen "${out_file}"; then
            save_and_announce "${out_file}"
            notify "Screen saved: ${out_file}"
            exit 0
        fi
        ;;
    window-copy)
        if capture_window "${out_file}" && copy_file_clipboard "${out_file}"; then
            save_and_announce "${out_file}"
            notify "Window copied + saved: ${out_file}"
            exit 0
        fi
        ;;
    window-save)
        if capture_window "${out_file}"; then
            save_and_announce "${out_file}"
            notify "Window saved: ${out_file}"
            exit 0
        fi
        ;;
    *)
        echo "usage: $0 {area-copy|area-save|screen-copy|screen-save|window-copy|window-save|open-dir}" >&2
        exit 1
        ;;
esac

if command -v grimblast >/dev/null 2>&1; then
    case "${mode}" in
        area-copy)
            grimblast copy area >/dev/null 2>&1 || true
            ;;
        area-save)
            grimblast save area "${out_file}" >/dev/null 2>&1 || true
            ;;
        screen-copy)
            grimblast copy screen >/dev/null 2>&1 || true
            ;;
        screen-save)
            grimblast save screen "${out_file}" >/dev/null 2>&1 || true
            ;;
        window-copy)
            grimblast copy active >/dev/null 2>&1 || true
            ;;
        window-save)
            grimblast save active "${out_file}" >/dev/null 2>&1 || true
            ;;
    esac
    [ -f "${out_file}" ] && cp "${out_file}" "${last_file}" || true
    notify "Screenshot processed (grimblast fallback)"
    exit 0
fi

if [ "${mode}" = "window-copy" ] || [ "${mode}" = "window-save" ]; then
    echo "window mode requires hyprctl + jq (or grimblast)" >&2
    exit 1
fi

if [ "${mode}" = "area-copy" ] || [ "${mode}" = "screen-copy" ] || [ "${mode}" = "window-copy" ]; then
    echo "wl-copy is required for copy modes" >&2
    exit 1
fi

if [ "${mode}" = "area-copy" ] || [ "${mode}" = "area-save" ]; then
    echo "slurp is required for area modes" >&2
    exit 1
fi

echo "unable to capture screenshot for mode: ${mode}" >&2
exit 1
