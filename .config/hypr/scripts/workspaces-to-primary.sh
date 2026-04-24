#!/bin/bash
# Move all workspaces to primary monitor (eDP-1)
# Triggered by: SUPER + CTRL + SHIFT + ALT + P

PRIMARY_MONITOR="eDP-1"

# Verify primary monitor exists
if ! hyprctl monitors -j | jq -e ".[] | select(.name == \"$PRIMARY_MONITOR\")" > /dev/null 2>&1; then
    notify-send "Hyprland Workspace Config" "Primary monitor $PRIMARY_MONITOR not found" -u critical
    exit 1
fi

# Move all workspaces (1-10) to primary monitor
for workspace in {1..10}; do
    hyprctl dispatch moveworkspacetomonitor "$workspace" "$PRIMARY_MONITOR" > /dev/null 2>&1
done

# Focus on workspace 1 on primary monitor
hyprctl dispatch workspace 1 > /dev/null 2>&1
hyprctl dispatch focusmonitor "$PRIMARY_MONITOR" > /dev/null 2>&1

notify-send "Hyprland Workspace Config" "All workspaces moved to $PRIMARY_MONITOR" -u normal
