#!/usr/bin/env sh
set -eu

prompt="Ajouter des applis au dock"
cfg_dir="${HOME}/.config/nwg-dock-hyprland"
pinned_list="${cfg_dir}/pinned.list"
pinned_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/nwg-dock-pinned"
pinned_config="${XDG_CONFIG_HOME:-${HOME}/.config}/nwg-dock-pinned"
launcher="${cfg_dir}/launch.sh"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Dock" "$1" >/dev/null 2>&1 || true
    fi
}

if ! command -v wofi >/dev/null 2>&1; then
    notify "wofi non installe"
    exit 1
fi

data_home="${XDG_DATA_HOME:-${HOME}/.local/share}"
data_dirs="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT HUP INT TERM

for base in "${data_home}" $(printf "%s" "${data_dirs}" | tr ':' ' '); do
    apps_dir="${base}/applications"
    [ -d "${apps_dir}" ] || continue
    find "${apps_dir}" -maxdepth 1 -type f -name "*.desktop" 2>/dev/null | while IFS= read -r desktop; do
        name="$(grep -m1 '^Name=' "${desktop}" | cut -d= -f2- || true)"
        [ -n "${name}" ] || continue
        if grep -q '^NoDisplay=true' "${desktop}" 2>/dev/null; then
            continue
        fi
        if grep -q '^Hidden=true' "${desktop}" 2>/dev/null; then
            continue
        fi
        printf "%s|%s\n" "${name}" "$(basename "${desktop}")" >> "${tmp_file}"
    done
done

if [ ! -s "${tmp_file}" ]; then
    notify "Aucune appli trouvee"
    exit 0
fi

picked="$(
    sort -t'|' -k1,1 "${tmp_file}" \
        | awk -F'|' '{print $1 " — " $2}' \
        | wofi --dmenu --prompt "${prompt}" --allow-markup
)"

[ -n "${picked:-}" ] || exit 0

picked_id="$(awk -F'|' -v choice="${picked}" '$1 " — " $2 == choice {print $2; exit}' "${tmp_file}")"
[ -n "${picked_id:-}" ] || exit 0
picked_id="${picked_id%.desktop}"

mkdir -p "${cfg_dir}"
touch "${pinned_list}"
if [ -s "${pinned_list}" ]; then
    sed -i 's/\.desktop$//' "${pinned_list}"
fi

load_pins_from_file() {
    file="$1"
    [ -f "${file}" ] || return 0
    if grep -q '"pinned"' "${file}" 2>/dev/null; then
        json="$(tr -d '\n' < "${file}")"
        printf "%s" "${json}" \
            | sed -n 's/.*"pinned"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' \
            | tr ',' '\n' \
            | sed 's/[[:space:]]//g; s/"//g; s/\\.desktop$//g' \
            | grep -E '.'
    else
        sed 's/[[:space:]]//g; s/\\.desktop$//g' "${file}" | grep -E '.'
    fi
}

if [ ! -s "${pinned_list}" ]; then
    load_pins_from_file "${pinned_cache}" >> "${pinned_list}" || true
fi
if [ ! -s "${pinned_list}" ]; then
    load_pins_from_file "${pinned_config}" >> "${pinned_list}" || true
fi

if ! grep -qxF "${picked_id}" "${pinned_list}"; then
    printf "%s\n" "${picked_id}" >> "${pinned_list}"
fi

mkdir -p "$(dirname "${pinned_cache}")"
sed '/^$/d' "${pinned_list}" > "${pinned_cache}"
cp -f "${pinned_cache}" "${pinned_config}" >/dev/null 2>&1 || true

notify "Ajoute au dock: ${picked_id}"

if [ -x "${launcher}" ]; then
    restart_cmd="sleep 0.2; pkill -x nwg-dock-hyprland || true; sleep 0.25; nohup '${launcher}' >/dev/null 2>&1 & sleep 0.4; pkill -RTMIN+2 -x nwg-dock-hyprland >/dev/null 2>&1 || true"
    if command -v setsid >/dev/null 2>&1; then
        setsid sh -lc "${restart_cmd}" >/dev/null 2>&1 &
    else
        nohup sh -lc "${restart_cmd}" >/dev/null 2>&1 &
    fi
else
    pkill -RTMIN+2 -x nwg-dock-hyprland >/dev/null 2>&1 || true
fi
