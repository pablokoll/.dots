#!/usr/bin/env bash
# Script to enable "kill window mode" in Hyprland
# Pressing Shift+Alt+K activates mode, cursor becomes X, clicking kills window, ESC cancels

# Change cursor to X (kill cursor)
hyprctl setcursor X_cursor 24

# Show notification
notify-send "Kill Mode" "Click on a window to close it (ESC to cancel)" -t 3000 -u normal

# Create a temporary file to store the mode state
MODE_FILE="/tmp/hyprland-kill-mode-$$"
touch "$MODE_FILE"

# Function to cleanup
cleanup() {
    rm -f "$MODE_FILE"
    # Reset cursor to default
    hyprctl setcursor default 24
    notify-send "Kill Mode" "Cancelled" -t 1000
    exit 0
}

# Set up trap for ESC key (we'll handle this via Hyprland binding)
trap cleanup EXIT INT TERM

# Wait for window click using hyprctl
# We'll use a different approach: activate a submap in Hyprland
echo "Kill mode activated. Click window to kill or press ESC to cancel."

# Keep script running until killed
while [ -f "$MODE_FILE" ]; do
    sleep 0.1
done
