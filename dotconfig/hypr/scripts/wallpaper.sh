#!/usr/bin/env sh

WALL="${HOME}/Pictures/wallpapers/current.jpg"

if [ -f "$WALL" ]; then
    swww img "$WALL" --transition-type grow --transition-pos 0.85,0.95 --transition-duration 1
fi
