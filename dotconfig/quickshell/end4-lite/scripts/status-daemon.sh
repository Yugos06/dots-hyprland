#!/usr/bin/env sh
set -eu

QS_DIR="${HOME}/.config/quickshell/end4-lite"
RUNTIME_DIR="${QS_DIR}/runtime"
STATUS_FILE="${RUNTIME_DIR}/status.json"

mkdir -p "${RUNTIME_DIR}"

escape_json() {
    printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

read_cpu_raw() {
    awk '/^cpu / {print $2 + $3 + $4 + $5 + $6 + $7 + $8, $5}' /proc/stat
}

prev_total=0
prev_idle=0
set -- $(read_cpu_raw)
prev_total="${1:-0}"
prev_idle="${2:-0}"

while :; do
    set -- $(read_cpu_raw)
    total="${1:-0}"
    idle="${2:-0}"
    diff_total=$((total - prev_total))
    diff_idle=$((idle - prev_idle))
    if [ "${diff_total}" -gt 0 ]; then
        cpu=$(( (100 * (diff_total - diff_idle)) / diff_total ))
    else
        cpu=0
    fi
    prev_total="${total}"
    prev_idle="${idle}"

    mem_pct="$(awk '
      /^MemTotal:/ {t=$2}
      /^MemAvailable:/ {a=$2}
      END {
        if (t > 0) {
          printf "%d", ((t-a)*100)/t
        } else {
          printf "0"
        }
      }' /proc/meminfo)"

    if command -v nmcli >/dev/null 2>&1; then
        net="$(nmcli -t -f STATE g 2>/dev/null | head -n1)"
        case "${net}" in
            connected)
                ssid="$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')"
                if [ -n "${ssid}" ]; then
                    network="wifi:${ssid}"
                else
                    network="connected"
                fi
                ;;
            connecting)
                network="connecting"
                ;;
            *)
                network="offline"
                ;;
        esac
    else
        network="offline"
    fi

    battery="n/a"
    for bat in /sys/class/power_supply/BAT*; do
        [ -d "${bat}" ] || continue
        cap="$(cat "${bat}/capacity" 2>/dev/null || echo "")"
        stat="$(cat "${bat}/status" 2>/dev/null || echo "")"
        if [ -n "${cap}" ]; then
            if [ "${stat}" = "Charging" ]; then
                battery="chg ${cap}%"
            else
                battery="${cap}%"
            fi
            break
        fi
    done

    media_title="No media"
    media_artist=""
    if command -v playerctl >/dev/null 2>&1; then
        title="$(playerctl metadata xesam:title 2>/dev/null || true)"
        artist="$(playerctl metadata xesam:artist 2>/dev/null || true)"
        if [ -n "${title}" ]; then
            media_title="${title}"
            media_artist="${artist}"
        fi
    fi

    esc_network="$(escape_json "${network}")"
    esc_battery="$(escape_json "${battery}")"
    esc_title="$(escape_json "${media_title}")"
    esc_artist="$(escape_json "${media_artist}")"

    cat > "${STATUS_FILE}" <<EOF
{
  "cpu": ${cpu},
  "memory": ${mem_pct},
  "network": "${esc_network}",
  "battery": "${esc_battery}",
  "media_title": "${esc_title}",
  "media_artist": "${esc_artist}",
  "notifications": 0
}
EOF

    sleep 2
done
