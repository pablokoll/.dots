#!/bin/bash
# Script to switch workspace pairs in Hyprland
# When switching to workspace N, also switch to its pair

WORKSPACE=$1

# Determine the pair based on odd/even
if [ $((WORKSPACE % 2)) -eq 1 ]; then
    # Odd workspace (laptop) - user wants focus on laptop
    ODD=$WORKSPACE
    EVEN=$((WORKSPACE + 1))
    FOCUS_MONITOR="eDP-1"
else
    # Even workspace (external monitor) - user wants focus on Samsung
    EVEN=$WORKSPACE
    ODD=$((WORKSPACE - 1))
    FOCUS_MONITOR="HDMI-A-1"
fi

# Switch to odd workspace on laptop (eDP-1)
hyprctl dispatch workspace $ODD

# Switch to even workspace on external monitor (HDMI-A-1)
hyprctl dispatch workspace $EVEN

# Set focus to the monitor corresponding to the workspace the user chose
hyprctl dispatch focusmonitor $FOCUS_MONITOR
