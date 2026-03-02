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
scripts/
  install.sh
```

## Quick start

1. Install packages: `hyprland quickshell waybar wofi mako kitty swww playerctl brightnessctl pamixer networkmanager`.
2. Optional packages for shortcuts: `grimblast hyprlock`.
3. Run installer: `./scripts/install.sh`
4. Start Hyprland.

## Installer options

- Default (copy mode + auto backup): `./scripts/install.sh`
- Symlink mode (best for editing this repo live): `./scripts/install.sh --mode symlink`
- Skip backup: `./scripts/install.sh --no-backup`
- Non-interactive: `./scripts/install.sh -y`

Backups are stored in `~/.config-backups/dots-hyprland-YYYYMMDD-HHMMSS`.

## Notes

- Edit monitor settings in `dotconfig/hypr/conf/10-monitors.conf`.
- Edit keybinds in `dotconfig/hypr/conf/40-keybinds.conf`.
- Tune colors in `dotconfig/waybar/style.css` and `dotconfig/wofi/style.css`.
- Quickshell profile lives in `dotconfig/quickshell/end4-lite`.
- Hyprland autostart launches `~/.config/hypr/scripts/start-shell.sh` (Quickshell first, fallback to Waybar/Mako).
- Quickshell live data is provided by `~/.config/quickshell/end4-lite/scripts/status-daemon.sh`.
- `SUPER+SPACE` opens a launcher action menu (apps, terminal, files, browser, screenshot, lock, power).
- Theme switch:
  - `~/.config/hypr/scripts/theme-switch.sh menu`
  - `~/.config/hypr/scripts/theme-switch.sh catppuccin|dark|light`
