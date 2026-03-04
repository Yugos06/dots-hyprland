#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODE="live"
STRICT=0

if [ -t 1 ]; then
    C_RESET="$(printf '\033[0m')"
    C_GREEN="$(printf '\033[32m')"
    C_YELLOW="$(printf '\033[33m')"
    C_RED="$(printf '\033[31m')"
else
    C_RESET=""
    C_GREEN=""
    C_YELLOW=""
    C_RED=""
fi

log() { printf "%s\n" "$*"; }
ok() { log "${C_GREEN}ok${C_RESET}    $*"; }
warn() { log "${C_YELLOW}warn${C_RESET}  $*"; }
err() { log "${C_RED}error${C_RESET} $*"; }

usage() {
    cat <<EOF
Usage: ./scripts/doctor.sh [options]

Options:
  --live               Check ~/.config files (default)
  --repo               Check repo files in dotconfig/
  --strict             Exit with code 1 on missing required packages
  -h, --help           Show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --live)
            MODE="live"
            shift
            ;;
        --repo)
            MODE="repo"
            shift
            ;;
        --strict)
            STRICT=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            err "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

missing_required=0
failed=0

check_cmd() {
    cmd="$1"
    label="$2"
    required="$3"

    if command -v "$cmd" >/dev/null 2>&1; then
        ok "found ${label} (${cmd})"
    else
        if [ "$required" -eq 1 ]; then
            if [ "$STRICT" -eq 1 ]; then
                err "missing ${label} (${cmd})"
                missing_required=$((missing_required + 1))
            else
                warn "missing ${label} (${cmd})"
            fi
        else
            warn "missing optional ${label} (${cmd})"
        fi
    fi
}

log "== Package checks =="
check_cmd "Hyprland" "Hyprland" 1
check_cmd "qs" "Quickshell" 1
check_cmd "waybar" "Waybar" 1
check_cmd "wofi" "Wofi" 1
check_cmd "mako" "Mako" 1
check_cmd "eww" "Eww" 0

# One graphical PolicyKit agent is needed for pkexec / GUI privilege prompts.
if command -v lxqt-policykit-agent >/dev/null 2>&1; then
    ok "found PolicyKit agent (lxqt-policykit-agent)"
elif command -v polkit-gnome-authentication-agent-1 >/dev/null 2>&1; then
    ok "found PolicyKit agent (polkit-gnome-authentication-agent-1)"
elif command -v polkit-kde-authentication-agent-1 >/dev/null 2>&1; then
    ok "found PolicyKit agent (polkit-kde-authentication-agent-1)"
elif command -v polkit-mate-authentication-agent-1 >/dev/null 2>&1; then
    ok "found PolicyKit agent (polkit-mate-authentication-agent-1)"
elif command -v xfce-polkit >/dev/null 2>&1; then
    ok "found PolicyKit agent (xfce-polkit)"
else
    if [ "$STRICT" -eq 1 ]; then
        err "missing PolicyKit agent (install one: lxqt-policykit / polkit-gnome / polkit-kde-agent / mate-polkit / xfce-polkit)"
        missing_required=$((missing_required + 1))
    else
        warn "missing PolicyKit agent (install one: lxqt-policykit / polkit-gnome / polkit-kde-agent / mate-polkit / xfce-polkit)"
    fi
fi

check_cmd "kitty" "Kitty" 1
check_cmd "swww" "swww" 1
check_cmd "playerctl" "playerctl" 1
check_cmd "brightnessctl" "brightnessctl" 1
check_cmd "pamixer" "pamixer" 1
check_cmd "nmcli" "NetworkManager" 1
check_cmd "grimblast" "grimblast" 0
check_cmd "jq" "jq" 0
check_cmd "sensors" "lm_sensors" 0
check_cmd "vnstat" "vnstat" 0
check_cmd "hyprlock" "hyprlock" 0

if [ "$STRICT" -eq 1 ] && [ "$missing_required" -gt 0 ]; then
    failed=1
fi

if [ "$MODE" = "repo" ]; then
    HYPR_CONFIG="${ROOT_DIR}/dotconfig/hypr/hyprland.conf"
    HYPR_DIR="${ROOT_DIR}/dotconfig/hypr"
    THEME_DIR="${ROOT_DIR}/dotconfig/themes"
else
    HYPR_CONFIG="${HOME}/.config/hypr/hyprland.conf"
    HYPR_DIR="${HOME}/.config/hypr"
    THEME_DIR="${HOME}/.config/themes"
fi

log ""
log "== File checks (${MODE}) =="
if [ -f "${HYPR_CONFIG}" ]; then
    ok "found ${HYPR_CONFIG}"
else
    err "missing ${HYPR_CONFIG}"
    failed=1
fi

for path in \
    "${HYPR_DIR}/scripts/start-shell.sh" \
    "${HYPR_DIR}/scripts/theme-switch.sh" \
    "${HYPR_DIR}/scripts/wallpaper.sh"
do
    if [ -f "${path}" ]; then
        if [ -x "${path}" ]; then
            ok "executable ${path}"
        else
            warn "not executable ${path}"
        fi
    else
        err "missing ${path}"
        failed=1
    fi
done

log ""
log "== Syntax checks (${MODE}) =="
if command -v rg >/dev/null 2>&1; then
    deprecated_count="$(rg -n --no-heading "windowrulev2|workspace_swipe|col\\.shadow" "${HYPR_DIR}" "${THEME_DIR}" 2>/dev/null | wc -l | tr -d ' ')"
    if [ "${deprecated_count}" = "0" ]; then
        ok "no deprecated syntax patterns found"
    else
        warn "deprecated syntax patterns found:"
        rg -n --no-heading "windowrulev2|workspace_swipe|col\\.shadow" "${HYPR_DIR}" "${THEME_DIR}" 2>/dev/null || true
        failed=1
    fi
else
    warn "rg not found, skipping deprecated syntax pattern scan"
fi

if command -v Hyprland >/dev/null 2>&1; then
    if [ "$MODE" = "repo" ]; then
        TMP_HOME="$(mktemp -d)"
        trap 'rm -rf "${TMP_HOME}"' EXIT HUP INT TERM
        mkdir -p "${TMP_HOME}/.config"
        ln -s "${ROOT_DIR}/dotconfig/hypr" "${TMP_HOME}/.config/hypr"
        verify_output="$(HOME="${TMP_HOME}" Hyprland --verify-config -c "${HYPR_CONFIG}" 2>&1 || true)"
    else
        verify_output="$(Hyprland --verify-config -c "${HYPR_CONFIG}" 2>&1 || true)"
    fi

    if printf "%s\n" "${verify_output}" | grep -q "config ok"; then
        ok "Hyprland --verify-config: config ok"
    else
        err "Hyprland --verify-config reported issues"
        printf "%s\n" "${verify_output}" | sed -n '/======== Config parsing result:/,$p'
        failed=1
    fi
else
    err "cannot run verify: Hyprland command not found"
    failed=1
fi

log ""
if [ "$failed" -eq 0 ]; then
    ok "doctor check passed"
    exit 0
fi

err "doctor check failed"
exit 1
