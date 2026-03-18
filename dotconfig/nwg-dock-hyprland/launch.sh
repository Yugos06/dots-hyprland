#!/usr/bin/env sh
set -eu

cfg_dir="${HOME}/.config/nwg-dock-hyprland"
style="style.css"

cd "${cfg_dir}"

exec nwg-dock-hyprland \
  -d \
  -hd 0 \
  -hl overlay \
  -p bottom \
  -i 28 \
  -a center \
  -mb 3 \
  -ml 3 \
  -mr 3 \
  -mt 0 \
  -c "${HOME}/.config/nwg-dock-hyprland/add-to-dock.sh" \
  -ico "/usr/share/icons/Papirus/24x24/actions/list-add.svg" \
  -s "${style}"
