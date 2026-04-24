#!/bin/bash
# Apply standard workspace configuration
# Odd workspaces (1,3,5,7,9) → eDP-1 (laptop)
# Even workspaces (2,4,6,8,10) → External monitor (HDMI-A-1, DP-11, or DP-12)
# Triggered by: SUPER + CTRL + SHIFT + ALT + S

PRIMARY_MONITOR="eDP-1"

# Detect which external monitor is connected
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -n 1)

# Validate monitors
if ! hyprctl monitors -j | jq -e ".[] | select(.name == \"$PRIMARY_MONITOR\")" > /dev/null 2>&1; then
    notify-send "Hyprland Workspace Config" "Primary monitor $PRIMARY_MONITOR not found" -u critical
    exit 1
fi

if [ -z "$EXTERNAL_MONITOR" ]; then
    notify-send "Hyprland Workspace Config" "No external monitor detected. Cannot apply standard configuration." -u critical
    exit 1
fi

# Move odd workspaces to laptop (eDP-1)
for workspace in 1 3 5 7 9; do
    hyprctl dispatch moveworkspacetomonitor "$workspace" "$PRIMARY_MONITOR" > /dev/null 2>&1
done

# Move even workspaces to external monitor
for workspace in 2 4 6 8 10; do
    hyprctl dispatch moveworkspacetomonitor "$workspace" "$EXTERNAL_MONITOR" > /dev/null 2>&1
done

# Focus on workspace 1 on laptop
hyprctl dispatch workspace 1 > /dev/null 2>&1
hyprctl dispatch focusmonitor "$PRIMARY_MONITOR" > /dev/null 2>&1

notify-send "Hyprland Workspace Config" "Standard config applied: Odd→$PRIMARY_MONITOR, Even→$EXTERNAL_MONITOR" -u normal
