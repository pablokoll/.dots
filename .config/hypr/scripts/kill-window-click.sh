#!/usr/bin/env bash
# Simple script to kill window on click
# Gets the window under cursor and kills it

# Get active window when clicked
ADDRESS=$(hyprctl activewindow -j | jq -r '.address')

if [ -n "$ADDRESS" ] && [ "$ADDRESS" != "null" ]; then
    hyprctl dispatch closewindow address:$ADDRESS
    notify-send "Window Closed" "Window killed successfully" -t 1000
else
    notify-send "Kill Mode" "No window found" -t 1000
fi
