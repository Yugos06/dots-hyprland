#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CFG_DIR="${HOME}/.config"
BACKUP_BASE="${HOME}/.config-backups"
MODE="copy"
WITH_BACKUP=1
ASSUME_YES=0

if [ -t 1 ]; then
    C_RESET="$(printf '\033[0m')"
    C_BOLD="$(printf '\033[1m')"
    C_GREEN="$(printf '\033[32m')"
    C_YELLOW="$(printf '\033[33m')"
    C_BLUE="$(printf '\033[34m')"
    C_RED="$(printf '\033[31m')"
else
    C_RESET=""
    C_BOLD=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_RED=""
fi

log() { printf "%s\n" "$*"; }
info() { log "${C_BLUE}info${C_RESET}  $*"; }
ok() { log "${C_GREEN}ok${C_RESET}    $*"; }
warn() { log "${C_YELLOW}warn${C_RESET}  $*"; }
err() { log "${C_RED}error${C_RESET} $*"; }

usage() {
    cat <<EOF
Usage: ./scripts/install.sh [options]

Options:
  --mode copy|symlink   Install by copy (default) or symlink
  --no-backup           Skip backup of existing config directories
  -y, --yes             Non-interactive mode
  -h, --help            Show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            [ $# -ge 2 ] || { err "--mode requires a value"; exit 1; }
            MODE="$2"
            shift 2
            ;;
        --no-backup)
            WITH_BACKUP=0
            shift
            ;;
        -y|--yes)
            ASSUME_YES=1
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

case "${MODE}" in
    copy|symlink) ;;
    *)
        err "Invalid mode: ${MODE}. Use copy or symlink."
        exit 1
        ;;
esac

SRC_ITEMS="hypr waybar wofi mako quickshell themes wallpapers eww hypr-dock nwg-dock-hyprland"
TOTAL_STEPS=6
STEP=1

step() {
    log "${C_BOLD}[${STEP}/${TOTAL_STEPS}]${C_RESET} $*"
    STEP=$((STEP + 1))
}

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        err "Required command not found: $1"
        exit 1
    fi
}

install_item_copy() {
    src="$1"
    dst="$2"
    mkdir -p "${dst}"
    cp -r "${src}/." "${dst}/"
}

install_item_symlink() {
    src="$1"
    dst="$2"
    rm -rf "${dst}"
    ln -s "${src}" "${dst}"
}

step "Checking installer dependencies"
need_cmd cp
need_cmd chmod
need_cmd mkdir
if [ "${MODE}" = "symlink" ]; then
    need_cmd ln
fi
ok "Dependencies look good"

step "Preparing target directories"
mkdir -p "${CFG_DIR}"
ok "Target: ${CFG_DIR}"

step "Backing up existing config (if needed)"
BACKUP_DIR=""
if [ "${WITH_BACKUP}" -eq 1 ]; then
    TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
    BACKUP_DIR="${BACKUP_BASE}/dots-hyprland-${TIMESTAMP}"
    for item in ${SRC_ITEMS}; do
        if [ -e "${CFG_DIR}/${item}" ] || [ -L "${CFG_DIR}/${item}" ]; then
            mkdir -p "${BACKUP_DIR}"
            mv "${CFG_DIR}/${item}" "${BACKUP_DIR}/${item}"
            warn "Backed up ${CFG_DIR}/${item} -> ${BACKUP_DIR}/${item}"
        fi
    done
    if [ -n "${BACKUP_DIR}" ] && [ -d "${BACKUP_DIR}" ]; then
        ok "Backup complete: ${BACKUP_DIR}"
    else
        info "No existing config to backup"
    fi
else
    info "Backup skipped (--no-backup)"
fi

if [ "${ASSUME_YES}" -ne 1 ] && [ -t 0 ]; then
    step "Confirming install plan"
    log "  mode: ${MODE}"
    log "  backup: $( [ "${WITH_BACKUP}" -eq 1 ] && printf "enabled" || printf "disabled" )"
    log "  destination: ${CFG_DIR}"
    printf "Proceed? [Y/n] "
    read -r answer
    case "${answer:-Y}" in
        y|Y|yes|YES|"") ;;
        *)
            warn "Installation cancelled"
            exit 0
            ;;
    esac
else
    step "Confirming install plan"
    info "Non-interactive mode enabled"
fi

step "Installing dotfiles"
for item in ${SRC_ITEMS}; do
    src="${ROOT_DIR}/dotconfig/${item}"
    dst="${CFG_DIR}/${item}"
    [ -d "${src}" ] || continue
    if [ "${MODE}" = "copy" ]; then
        install_item_copy "${src}" "${dst}"
    else
        install_item_symlink "${src}" "${dst}"
    fi
    ok "Installed ${item}"
done

chmod +x "${CFG_DIR}/hypr/scripts/"*.sh
chmod +x "${CFG_DIR}/quickshell/end4-lite/scripts/"*.sh
chmod +x "${CFG_DIR}/eww/scripts/"*.sh
if [ -d "${CFG_DIR}/waybar/scripts" ]; then
    chmod +x "${CFG_DIR}/waybar/scripts/"*
fi
if [ -f "${CFG_DIR}/nwg-dock-hyprland/launch.sh" ]; then
    chmod +x "${CFG_DIR}/nwg-dock-hyprland/launch.sh"
fi
if [ -f "${CFG_DIR}/nwg-dock-hyprland/apply-icon-overrides.sh" ]; then
    chmod +x "${CFG_DIR}/nwg-dock-hyprland/apply-icon-overrides.sh"
fi
if [ -f "${CFG_DIR}/nwg-dock-hyprland/add-to-dock.sh" ]; then
    chmod +x "${CFG_DIR}/nwg-dock-hyprland/add-to-dock.sh"
fi

step "Reloading Hyprland (if running)"
if command -v hyprctl >/dev/null 2>&1; then
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload >/dev/null 2>&1 || true
        ok "Hyprland reloaded"
    else
        info "Hyprland not running; skip reload"
    fi
else
    info "hyprctl not found; skip reload"
fi

log ""
log "${C_BOLD}${C_GREEN}Installation complete${C_RESET}"
log "  mode: ${MODE}"
log "  config: ${CFG_DIR}"
if [ -n "${BACKUP_DIR}" ] && [ -d "${BACKUP_DIR}" ]; then
    log "  backup: ${BACKUP_DIR}"
fi
log "  next: restart Hyprland session"
