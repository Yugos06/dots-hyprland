#!/usr/bin/env sh
set -eu

# Start one graphical polkit agent for GUI privilege prompts (pkexec).
[ -n "${WAYLAND_DISPLAY:-}" ] || exit 0

if pgrep -f "polkit-gnome-authentication-agent-1|lxqt-policykit-agent|polkit-kde-authentication-agent-1|polkit-mate-authentication-agent-1|xfce-polkit" >/dev/null 2>&1; then
    exit 0
fi

start_agent() {
    agent="$1"
    [ -x "${agent}" ] || return 1
    nohup "${agent}" >/dev/null 2>&1 &
    exit 0
}

for path in \
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
    /usr/lib/lxqt-policykit/lxqt-policykit-agent \
    /usr/lib/lxqt-policykit-agent \
    /usr/lib/polkit-kde-authentication-agent-1 \
    /usr/lib/polkit-kde-agent-1 \
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 \
    /usr/lib/xfce-polkit/xfce-polkit
do
    start_agent "${path}" || true
done

if command -v lxqt-policykit-agent >/dev/null 2>&1; then
    nohup lxqt-policykit-agent >/dev/null 2>&1 &
    exit 0
fi

if command -v polkit-gnome-authentication-agent-1 >/dev/null 2>&1; then
    nohup polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &
    exit 0
fi

if command -v polkit-kde-authentication-agent-1 >/dev/null 2>&1; then
    nohup polkit-kde-authentication-agent-1 >/dev/null 2>&1 &
    exit 0
fi

if command -v polkit-mate-authentication-agent-1 >/dev/null 2>&1; then
    nohup polkit-mate-authentication-agent-1 >/dev/null 2>&1 &
    exit 0
fi

if command -v xfce-polkit >/dev/null 2>&1; then
    nohup xfce-polkit >/dev/null 2>&1 &
    exit 0
fi

exit 0
