# dots-hyprland

Hyprland dotfiles with a modular structure inspired by end-4 and a neon purple look.

## Layout

```text
dotconfig/
  hypr/
    hyprland.conf
    conf/
      00-env.conf
      10-monitors.conf
      20-input.conf
      30-autostart.conf
      40-keybinds.conf
      50-rules.conf
      60-animations.conf
      90-theme.conf
    scripts/
      launchers.sh
      wallpaper.sh
  waybar/
    config.jsonc
    style.css
  wofi/
    config
    style.css
  mako/
    config
  quickshell/
    end4-lite/
      shell.qml
      runtime/status.json
      modules/
      services/
      panelFamilies/
      assets/
      defaults/
      scripts/
      translations/
  themes/
    current.theme
    catppuccin/
    dark/
    light/
  wallpapers/
scripts/
  install.sh
  doctor.sh
```

## Quick start

1. Install packages: `hyprland quickshell waybar wofi mako kitty swww playerctl brightnessctl pamixer networkmanager`.
2. Optional packages for shortcuts: `grimblast hyprlock`.
3. Optional for wallpaper color extraction: `imagemagick` (`magick` command).
4. Run installer: `./scripts/install.sh`
5. Start Hyprland.

## Installer options

- Default (copy mode + auto backup): `./scripts/install.sh`
- Symlink mode (best for editing this repo live): `./scripts/install.sh --mode symlink`
- Skip backup: `./scripts/install.sh --no-backup`
- Non-interactive: `./scripts/install.sh -y`

Backups are stored in `~/.config-backups/dots-hyprland-YYYYMMDD-HHMMSS`.

## Doctor / diagnostics

Run quick checks for packages, file presence, deprecated syntax patterns, and `Hyprland --verify-config`.

- Check live config (`~/.config`): `./scripts/doctor.sh --live`
- Check repo config (`dotconfig/`): `./scripts/doctor.sh --repo`
- Fail on missing required packages too: `./scripts/doctor.sh --repo --strict`

## Notes

- Edit monitor settings in `dotconfig/hypr/conf/10-monitors.conf`.
- Edit keybinds in `dotconfig/hypr/conf/40-keybinds.conf`.
- Tune colors in `dotconfig/waybar/style.css` and `dotconfig/wofi/style.css`.
- Quickshell profile lives in `dotconfig/quickshell/end4-lite`.
- Hyprland autostart launches `~/.config/hypr/scripts/start-shell.sh` (Quickshell first, fallback to Waybar/Mako).
- Quickshell live data is provided by `~/.config/quickshell/end4-lite/scripts/status-daemon.sh`.
- Quickshell also includes a bottom dock (`modules/dock/BottomDock.qml`) for fast app launch.
- Wallpaper folder: `~/.config/wallpapers`.
- Wallpaper binds:
  - `SUPER+W`: wallpaper menu
  - `SUPER+SHIFT+W`: random wallpaper
- Wallpaper apply script updates `~/.config/hypr/conf/96-wallpaper-colors.conf` so borders/shadows adapt to wallpaper colors.
- `SUPER+SPACE` opens the actions launcher.
- `SUPER+A` opens the app launcher (`wofi drun` with app icons), `SUPER+SHIFT+A` opens `wofi run`.
- Dock controls:
  - `Icons`: toggle icon visibility on dock buttons
  - `No Focus`: hide dock until Quickshell restart
- Waybar has 2 dedicated launcher pills (left side):
  - apps launcher (left click: apps, right click: run)
  - actions launcher (left click: actions menu, right click: theme menu)
- Screenshots:
  - `Print`: area to clipboard
  - `Shift+Print`: full screen to clipboard
  - `SUPER+Print`: area to file (`~/Pictures/Screenshots`)
- Theme switch:
  - `~/.config/hypr/scripts/theme-switch.sh menu`
  - `~/.config/hypr/scripts/theme-switch.sh catppuccin|dark|light`
- Workspace binds:
  - QWERTY: `SUPER+1..0` to switch, `SUPER+SHIFT+1..0` to move window.
  - AZERTY top row: `SUPER+& é " ' ( - è _ ç à` (same logic as above).
