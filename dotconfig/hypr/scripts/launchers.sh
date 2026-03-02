#!/usr/bin/env sh

case "$1" in
    app)
        wofi --show drun
        ;;
    run)
        wofi --show run
        ;;
    *)
        echo "usage: $0 {app|run}"
        exit 1
        ;;
esac
