#!/usr/bin/env sh
set -eu

cfg_dir="${HOME}/.config/nwg-dock-hyprland"
overrides="${cfg_dir}/icon-overrides.conf"
target_dir="${HOME}/.local/share/applications"

[ -f "${overrides}" ] || exit 0

find_desktop() {
    name="$1"
    for base in /usr/share/applications /usr/local/share/applications; do
        if [ -f "${base}/${name}" ]; then
            printf "%s\n" "${base}/${name}"
            return 0
        fi
    done
    return 1
}

apply_override() {
    desktop_name="$1"
    icon_value="$2"

    src="$(find_desktop "${desktop_name}")" || return 0
    mkdir -p "${target_dir}"
    dst="${target_dir}/${desktop_name}"
    cp "${src}" "${dst}"

    if grep -q '^Icon=' "${dst}"; then
        sed -i "s|^Icon=.*|Icon=${icon_value}|" "${dst}"
    else
        printf "\nIcon=%s\n" "${icon_value}" >> "${dst}"
    fi
}

while IFS='|' read -r desktop icon; do
    desktop="$(printf "%s" "${desktop:-}" | xargs)"
    icon="$(printf "%s" "${icon:-}" | xargs)"
    case "${desktop}" in
        ""|\#*) continue ;;
    esac

    if [ -z "${icon}" ]; then
        continue
    fi

    if [ "${icon#/}" != "${icon}" ] && [ ! -f "${icon}" ]; then
        continue
    fi

    apply_override "${desktop}" "${icon}"
done < "${overrides}"
