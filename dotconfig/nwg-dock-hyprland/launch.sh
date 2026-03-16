#!/usr/bin/env sh
set -eu

cfg_dir="${HOME}/.config/nwg-dock-hyprland"
style="style.css"

cd "${cfg_dir}"

exec nwg-dock-hyprland \
  -r \
  -p bottom \
  -i 40 \
  -a center \
  -mb 6 \
  -ml 6 \
  -mr 6 \
  -mt 0 \
  -s "${style}"
