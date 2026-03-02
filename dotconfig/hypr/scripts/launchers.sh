#!/usr/bin/env sh

case "$1" in
    app)
        exec wofi --show drun --allow-images --prompt "Applications"
        ;;
    run)
        exec wofi --show run --prompt "Run"
        ;;
    *)
        echo "usage: $0 {app|run}"
        exit 1
        ;;
esac
