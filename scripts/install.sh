#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CFG_DIR="${HOME}/.config"

mkdir -p "${CFG_DIR}/hypr" "${CFG_DIR}/waybar" "${CFG_DIR}/wofi" "${CFG_DIR}/mako" "${CFG_DIR}/quickshell"
mkdir -p "${CFG_DIR}/themes"

cp -r "${ROOT_DIR}/dotconfig/hypr/." "${CFG_DIR}/hypr/"
cp -r "${ROOT_DIR}/dotconfig/waybar/." "${CFG_DIR}/waybar/"
cp -r "${ROOT_DIR}/dotconfig/wofi/." "${CFG_DIR}/wofi/"
cp -r "${ROOT_DIR}/dotconfig/mako/." "${CFG_DIR}/mako/"
cp -r "${ROOT_DIR}/dotconfig/quickshell/." "${CFG_DIR}/quickshell/"
cp -r "${ROOT_DIR}/dotconfig/themes/." "${CFG_DIR}/themes/"

chmod +x "${CFG_DIR}/hypr/scripts/"*.sh
chmod +x "${CFG_DIR}/quickshell/end4-lite/scripts/"*.sh

echo "Installed configs to ${CFG_DIR}"
