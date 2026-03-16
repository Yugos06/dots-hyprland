#!/usr/bin/env sh
set -eu

mode="${1:-add}"
target_id="${2:-}"

qs_dir="${HOME}/.config/quickshell/end4-lite"
runtime_dir="${qs_dir}/runtime"
apps_file="${runtime_dir}/dock-apps.list"

mkdir -p "${runtime_dir}"
[ -f "${apps_file}" ] || touch "${apps_file}"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Dock" "$1" >/dev/null 2>&1 || true
    fi
}

app_ids="brave discord spotify steam code telegram"

has_id() {
    app_id="$1"
    awk -F'|' -v id="${app_id}" '$1 == id { found = 1 } END { exit found ? 0 : 1 }' "${apps_file}"
}

app_label() {
    case "$1" in
        brave) printf "%s\n" "Brave" ;;
        discord) printf "%s\n" "Discord" ;;
        spotify) printf "%s\n" "Spotify" ;;
        steam) printf "%s\n" "Steam" ;;
        code) printf "%s\n" "VS Code" ;;
        telegram) printf "%s\n" "Telegram" ;;
        *) return 1 ;;
    esac
}

app_icon_candidates() {
    case "$1" in
        brave) printf "%s\n" "/usr/share/icons/Papirus/64x64/apps/brave-browser.svg;/usr/share/icons/Papirus/48x48/apps/brave-browser.svg;/usr/share/icons/Papirus/24x24/apps/brave-browser.svg;/usr/share/icons/hicolor/scalable/apps/brave-browser.svg;/usr/share/icons/hicolor/256x256/apps/brave-browser.png;/usr/share/icons/hicolor/128x128/apps/brave-browser.png" ;;
        discord) printf "%s\n" "/usr/share/icons/Papirus/64x64/apps/discord.svg;/usr/share/icons/Papirus/48x48/apps/discord.svg;/usr/share/icons/Papirus/24x24/apps/discord.svg;/usr/share/icons/hicolor/scalable/apps/discord.svg;/usr/share/icons/hicolor/256x256/apps/discord.png;/usr/share/icons/hicolor/128x128/apps/discord.png" ;;
        spotify) printf "%s\n" "/usr/share/icons/Papirus/64x64/apps/spotify-client.svg;/usr/share/icons/Papirus/48x48/apps/spotify-client.svg;/usr/share/icons/Papirus/24x24/apps/spotify-client.svg;/usr/share/icons/hicolor/scalable/apps/spotify-client.svg;/usr/share/icons/hicolor/256x256/apps/spotify-client.png;/usr/share/icons/hicolor/128x128/apps/spotify-client.png" ;;
        steam) printf "%s\n" "/usr/share/icons/Papirus/64x64/apps/steam.svg;/usr/share/icons/Papirus/48x48/apps/steam.svg;/usr/share/icons/Papirus/24x24/apps/steam.svg;/usr/share/icons/hicolor/scalable/apps/steam.svg;/usr/share/icons/hicolor/256x256/apps/steam.png;/usr/share/icons/hicolor/128x128/apps/steam.png" ;;
        code) printf "%s\n" "/usr/share/icons/Papirus/64x64/apps/code.svg;/usr/share/icons/Papirus/48x48/apps/code.svg;/usr/share/icons/Papirus/24x24/apps/code.svg;/usr/share/icons/hicolor/scalable/apps/code.svg;/usr/share/icons/hicolor/scalable/apps/com.visualstudio.code.oss.svg;/usr/share/icons/hicolor/256x256/apps/code.png;/usr/share/icons/hicolor/256x256/apps/com.visualstudio.code.oss.png" ;;
        telegram) printf "%s\n" "/usr/share/icons/Papirus/64x64/apps/telegram.svg;/usr/share/icons/Papirus/48x48/apps/telegram.svg;/usr/share/icons/Papirus/24x24/apps/telegram.svg;/usr/share/icons/hicolor/scalable/apps/telegram.svg;/usr/share/icons/hicolor/scalable/apps/telegram-desktop.svg;/usr/share/icons/hicolor/256x256/apps/telegram.png;/usr/share/icons/hicolor/256x256/apps/telegram-desktop.png" ;;
        *) return 1 ;;
    esac
}

app_icon_names() {
    case "$1" in
        brave) printf "%s\n" "brave-browser brave" ;;
        discord) printf "%s\n" "discord discord-canary com.discordapp.Discord" ;;
        spotify) printf "%s\n" "spotify spotify-client" ;;
        steam) printf "%s\n" "steam steam-native com.valvesoftware.Steam" ;;
        code) printf "%s\n" "code code-oss com.visualstudio.code com.visualstudio.code.oss visual-studio-code" ;;
        telegram) printf "%s\n" "telegram telegram-desktop org.telegram.desktop" ;;
        *) return 1 ;;
    esac
}

find_icon() {
    icon_name="$1"
    icon_bases="${HOME}/.local/share/icons /var/lib/flatpak/exports/share/icons /usr/share/icons"
    icon_rel_dirs="Papirus/64x64/apps Papirus/48x48/apps Papirus/32x32/apps Papirus/24x24/apps hicolor/scalable/apps hicolor/256x256/apps hicolor/128x128/apps hicolor/64x64/apps hicolor/48x48/apps hicolor/32x32/apps hicolor/24x24/apps"

    for base in ${icon_bases}; do
        for rel in ${icon_rel_dirs}; do
            for ext in svg png; do
                candidate="${base}/${rel}/${icon_name}.${ext}"
                if [ -f "${candidate}" ]; then
                    printf "%s\n" "${candidate}"
                    return 0
                fi
            done
        done
    done
    return 1
}

find_symbolic_icon() {
    icon_name="$1"
    icon_bases="${HOME}/.local/share/icons /var/lib/flatpak/exports/share/icons /usr/share/icons"
    icon_rel_dirs="hicolor/symbolic/apps Papirus/symbolic/apps"

    for base in ${icon_bases}; do
        for rel in ${icon_rel_dirs}; do
            for ext in svg png; do
                candidate="${base}/${rel}/${icon_name}-symbolic.${ext}"
                if [ -f "${candidate}" ]; then
                    printf "%s\n" "${candidate}"
                    return 0
                fi
            done
        done
    done
    return 1
}

app_command() {
    case "$1" in
        brave)
            printf "%s\n" "sh -lc 'command -v brave-browser >/dev/null 2>&1 && exec brave-browser; command -v brave >/dev/null 2>&1 && exec brave; exec xdg-open https://brave.com'"
            ;;
        discord)
            printf "%s\n" "sh -lc 'command -v discord >/dev/null 2>&1 && exec discord; command -v vesktop >/dev/null 2>&1 && exec vesktop; exec xdg-open https://discord.com/app'"
            ;;
        spotify)
            printf "%s\n" "sh -lc 'command -v spotify >/dev/null 2>&1 && exec spotify; exec xdg-open https://open.spotify.com'"
            ;;
        steam)
            printf "%s\n" "sh -lc 'command -v steam >/dev/null 2>&1 && exec steam; exec xdg-open steam://open/main'"
            ;;
        code)
            printf "%s\n" "sh -lc 'command -v code >/dev/null 2>&1 && exec code; exec xdg-open https://code.visualstudio.com'"
            ;;
        telegram)
            printf "%s\n" "sh -lc 'command -v telegram-desktop >/dev/null 2>&1 && exec telegram-desktop; command -v telegram >/dev/null 2>&1 && exec telegram; exec xdg-open https://web.telegram.org'"
            ;;
        *)
            return 1
            ;;
    esac
}

pick_icon() {
    icon_candidates="$1"
    icon_names="${2:-}"
    old_ifs="${IFS}"
    IFS=";"
    for candidate in ${icon_candidates}; do
        case "${candidate}" in
            *symbolic*) continue ;;
        esac
        if [ -f "${candidate}" ]; then
            IFS="${old_ifs}"
            printf "%s\n" "${candidate}"
            return 0
        fi
    done
    IFS="${old_ifs}"

    if [ -n "${icon_names}" ]; then
        for icon_name in ${icon_names}; do
            if icon_path="$(find_icon "${icon_name}")"; then
                printf "%s\n" "${icon_path}"
                return 0
            fi
        done
        for icon_name in ${icon_names}; do
            if icon_path="$(find_symbolic_icon "${icon_name}")"; then
                printf "%s\n" "${icon_path}"
                return 0
            fi
        done
    fi

    printf "%s\n" "/usr/share/icons/Papirus/24x24/mimetypes/application-x-executable.svg"
}

write_entry() {
    app_id="$1"
    label="$(app_label "${app_id}")"
    icon="$(pick_icon "$(app_icon_candidates "${app_id}")" "$(app_icon_names "${app_id}")")"
    command="$(app_command "${app_id}")"
    printf "%s|%s|%s|%s\n" "${app_id}" "${label}" "${icon}" "${command}" >> "${apps_file}"
}

add_app() {
    app_id="$1"
    case " ${app_ids} " in
        *" ${app_id} "*) ;;
        *)
            echo "unknown app id: ${app_id}" >&2
            exit 1
            ;;
    esac

    if has_id "${app_id}"; then
        notify "${app_id} est deja dans le dock"
        return 0
    fi
    write_entry "${app_id}"
    notify "$(app_label "${app_id}") ajoute au dock"
}

remove_app() {
    app_id="$1"
    if ! has_id "${app_id}"; then
        notify "${app_id} absent du dock"
        return 0
    fi
    tmp_file="$(mktemp)"
    awk -F'|' -v id="${app_id}" '$1 != id' "${apps_file}" > "${tmp_file}"
    mv "${tmp_file}" "${apps_file}"
    notify "${app_id} retire du dock"
}

choose_add() {
    tmp_file="$(mktemp)"
    trap 'rm -f "${tmp_file}"' EXIT HUP INT TERM

    for app_id in ${app_ids}; do
        if ! has_id "${app_id}"; then
            printf "%s|%s\n" "${app_id}" "$(app_label "${app_id}")" >> "${tmp_file}"
        fi
    done

    if [ ! -s "${tmp_file}" ]; then
        notify "Toutes les apps proposees sont deja ajoutees"
        exit 0
    fi

    if command -v wofi >/dev/null 2>&1; then
        picked_label="$(cut -d'|' -f2 "${tmp_file}" | wofi --dmenu --prompt "Add app to dock")"
    else
        picked_label="$(cut -d'|' -f2 "${tmp_file}" | head -n1)"
    fi

    [ -n "${picked_label:-}" ] || exit 0
    picked_id="$(awk -F'|' -v label="${picked_label}" '$2 == label { print $1; exit }' "${tmp_file}")"
    [ -n "${picked_id:-}" ] || exit 1
    add_app "${picked_id}"
}

choose_remove() {
    tmp_file="$(mktemp)"
    trap 'rm -f "${tmp_file}"' EXIT HUP INT TERM
    awk -F'|' 'NF >= 4 { print $1 "|" $2 }' "${apps_file}" > "${tmp_file}"

    if [ ! -s "${tmp_file}" ]; then
        notify "Aucune app dynamique a retirer"
        exit 0
    fi

    if command -v wofi >/dev/null 2>&1; then
        picked_label="$(cut -d'|' -f2 "${tmp_file}" | wofi --dmenu --prompt "Remove app from dock")"
    else
        picked_label="$(cut -d'|' -f2 "${tmp_file}" | head -n1)"
    fi

    [ -n "${picked_label:-}" ] || exit 0
    picked_id="$(awk -F'|' -v label="${picked_label}" '$2 == label { print $1; exit }' "${tmp_file}")"
    [ -n "${picked_id:-}" ] || exit 1
    remove_app "${picked_id}"
}

refresh_icons() {
    tmp_file="$(mktemp)"
    trap 'rm -f "${tmp_file}"' EXIT HUP INT TERM

    while IFS= read -r line; do
        case "${line}" in
            ""|\#*) printf "%s\n" "${line}" >> "${tmp_file}"; continue ;;
            *"|"*"|"*"|"*) ;;
            *) printf "%s\n" "${line}" >> "${tmp_file}"; continue ;;
        esac

        app_id="${line%%|*}"
        rest="${line#*|}"
        label="${rest%%|*}"
        rest="${rest#*|}"
        icon="${rest%%|*}"
        command="${rest#*|}"

        if app_icon_candidates "${app_id}" >/dev/null 2>&1; then
            icon="$(pick_icon "$(app_icon_candidates "${app_id}")" "$(app_icon_names "${app_id}")")"
            printf "%s|%s|%s|%s\n" "${app_id}" "${label}" "${icon}" "${command}" >> "${tmp_file}"
        else
            printf "%s\n" "${line}" >> "${tmp_file}"
        fi
    done < "${apps_file}"

    mv "${tmp_file}" "${apps_file}"
    trap - EXIT HUP INT TERM
}

case "${mode}" in
    add)
        if [ -n "${target_id}" ]; then
            add_app "${target_id}"
        else
            choose_add
        fi
        ;;
    remove)
        if [ -n "${target_id}" ]; then
            remove_app "${target_id}"
        else
            choose_remove
        fi
        ;;
    list)
        if [ -s "${apps_file}" ]; then
            cat "${apps_file}"
        fi
        ;;
    refresh)
        refresh_icons
        ;;
    clear)
        : > "${apps_file}"
        notify "Dock dynamique vide"
        ;;
    *)
        echo "usage: $0 {add|remove|list|clear} [app-id]" >&2
        exit 1
        ;;
esac
