#!/usr/bin/env sh
set -eu

mode="${1:-cpu_usage}"

human_rate() {
    bps="$1"
    if [ "${bps}" -ge 1073741824 ]; then
        awk -v v="${bps}" 'BEGIN {printf "%.1f GB/s", v/1073741824}'
    elif [ "${bps}" -ge 1048576 ]; then
        awk -v v="${bps}" 'BEGIN {printf "%.1f MB/s", v/1048576}'
    elif [ "${bps}" -ge 1024 ]; then
        awk -v v="${bps}" 'BEGIN {printf "%.1f KB/s", v/1024}'
    else
        printf "%s B/s" "${bps}"
    fi
}

human_size() {
    bytes="$1"
    if [ "${bytes}" -ge 1073741824 ]; then
        awk -v v="${bytes}" 'BEGIN {printf "%.1f GB", v/1073741824}'
    elif [ "${bytes}" -ge 1048576 ]; then
        awk -v v="${bytes}" 'BEGIN {printf "%.1f MB", v/1048576}'
    elif [ "${bytes}" -ge 1024 ]; then
        awk -v v="${bytes}" 'BEGIN {printf "%.1f KB", v/1024}'
    else
        printf "%s B" "${bytes}"
    fi
}

cpu_name() {
    awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || echo "Unknown CPU"
}

cpu_temp() {
    if command -v sensors >/dev/null 2>&1; then
        val="$(sensors 2>/dev/null | awk '
          /Package id 0:|Tctl:|temp1:|edge:/ {
            for (i=1; i<=NF; i++) {
              if ($i ~ /^\+[0-9]+(\.[0-9]+)?°C$/) {
                gsub(/[+°C]/, "", $i);
                printf "%d\n", $i;
                exit
              }
            }
          }')"
        if [ -n "${val}" ]; then
            printf "%s\n" "${val}"
            return
        fi
    fi

    for zone in /sys/class/thermal/thermal_zone*/temp; do
        [ -f "${zone}" ] || continue
        raw="$(cat "${zone}" 2>/dev/null || true)"
        if [ -n "${raw}" ] && [ "${raw}" -gt 0 ] 2>/dev/null; then
            printf "%d\n" "$((raw / 1000))"
            return
        fi
    done

    printf "0\n"
}

cpu_usage() {
    state_file="/tmp/eww-cpu.state"
    set -- $(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat)
    total="${1:-0}"
    idle="${2:-0}"

    if [ -f "${state_file}" ]; then
        read -r prev_total prev_idle < "${state_file}" || {
            prev_total="${total}"
            prev_idle="${idle}"
        }
    else
        prev_total="${total}"
        prev_idle="${idle}"
    fi

    diff_total=$((total - prev_total))
    diff_idle=$((idle - prev_idle))

    usage=0
    if [ "${diff_total}" -gt 0 ]; then
        usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
    fi

    printf "%s %s\n" "${total}" "${idle}" > "${state_file}"
    printf "%s\n" "${usage}"
}

gpu_name() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1
        return
    fi

    if command -v lspci >/dev/null 2>&1; then
        lspci | awk -F': ' '/VGA compatible controller|3D controller/ {print $2; exit}'
        return
    fi

    printf "Integrated GPU\n"
}

gpu_temp() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1
        return
    fi

    if command -v sensors >/dev/null 2>&1; then
        val="$(sensors 2>/dev/null | awk '/amdgpu|edge:|temp1:/ {
          for (i=1; i<=NF; i++) {
            if ($i ~ /^\+[0-9]+(\.[0-9]+)?°C$/) {
              gsub(/[+°C]/, "", $i);
              printf "%d\n", $i;
              exit
            }
          }
        }')"
        if [ -n "${val}" ]; then
            printf "%s\n" "${val}"
            return
        fi
    fi

    printf "0\n"
}

gpu_usage() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1
        return
    fi

    for busy in /sys/class/drm/card*/device/gpu_busy_percent; do
        [ -f "${busy}" ] || continue
        cat "${busy}" 2>/dev/null
        return
    done

    printf "0\n"
}

ram_percent() {
    free -m | awk '/^Mem:/ {if ($2 > 0) printf "%d\n", ($3 * 100) / $2; else print "0"}'
}

ram_text() {
    free -m | awk '/^Mem:/ {printf "%.1f / %.1f GiB\n", $3 / 1024, $2 / 1024}'
}

disk_percent() {
    df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}'
}

disk_text() {
    df -h / | awk 'NR==2 {print $3 " / " $2}'
}

disk_name() {
    df -P / | awk 'NR==2 {gsub("/dev/", "", $1); print $1}'
}

net_iface() {
    iface="$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')"
    if [ -n "${iface}" ]; then
        printf "%s\n" "${iface}"
        return
    fi

    for c in /sys/class/net/*; do
        [ -d "${c}" ] || continue
        cand="$(basename "${c}")"
        [ "${cand}" = "lo" ] && continue
        printf "%s\n" "${cand}"
        return
    done

    printf "lo\n"
}

net_text() {
    iface="$(net_iface)"
    rx_path="/sys/class/net/${iface}/statistics/rx_bytes"
    tx_path="/sys/class/net/${iface}/statistics/tx_bytes"
    [ -f "${rx_path}" ] || {
        printf "Download --\nUpload   --\nIface    n/a\n"
        return
    }

    rx="$(cat "${rx_path}" 2>/dev/null || echo 0)"
    tx="$(cat "${tx_path}" 2>/dev/null || echo 0)"
    now="$(date +%s)"

    state_file="/tmp/eww-net-${iface}.state"
    if [ -f "${state_file}" ]; then
        read -r prev_rx prev_tx prev_t < "${state_file}" || {
            prev_rx="${rx}"
            prev_tx="${tx}"
            prev_t="${now}"
        }
    else
        prev_rx="${rx}"
        prev_tx="${tx}"
        prev_t="${now}"
    fi

    dt=$((now - prev_t))
    [ "${dt}" -gt 0 ] || dt=1

    down_bps=$(( (rx - prev_rx) / dt ))
    up_bps=$(( (tx - prev_tx) / dt ))
    [ "${down_bps}" -ge 0 ] || down_bps=0
    [ "${up_bps}" -ge 0 ] || up_bps=0

    printf "%s %s %s\n" "${rx}" "${tx}" "${now}" > "${state_file}"

    down="$(human_rate "${down_bps}")"
    up="$(human_rate "${up_bps}")"
    total_rx="$(human_size "${rx}")"
    total_tx="$(human_size "${tx}")"

    printf "Download %s\nUpload   %s\nTotal    %s / %s\n" "${down}" "${up}" "${total_rx}" "${total_tx}"
}

case "${mode}" in
    cpu_name) cpu_name ;;
    cpu_temp) cpu_temp ;;
    cpu_usage) cpu_usage ;;
    gpu_name) gpu_name ;;
    gpu_temp) gpu_temp ;;
    gpu_usage) gpu_usage ;;
    ram_percent) ram_percent ;;
    ram_text) ram_text ;;
    disk_percent) disk_percent ;;
    disk_text) disk_text ;;
    disk_name) disk_name ;;
    net_text) net_text ;;
    stamp) date +%H:%M:%S ;;
    *)
        echo "usage: $0 {cpu_name|cpu_temp|cpu_usage|gpu_name|gpu_temp|gpu_usage|ram_percent|ram_text|disk_percent|disk_text|disk_name|net_text|stamp}" >&2
        exit 1
        ;;
esac
