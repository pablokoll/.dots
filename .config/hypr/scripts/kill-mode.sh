#!/usr/bin/env bash
# Kill window mode for Hyprland
# Usage: kill-mode.sh [activate|cancel|kill]

case "$1" in
    activate)
        # Change cursor to crosshair/kill cursor
        hyprctl setcursor X_cursor 24 2>/dev/null || hyprctl setcursor crosshair 24 2>/dev/null

        # Show notification
        notify-send -u normal -t 2000 "🎯 Kill Mode" "Click any window to close it\nPress ESC to cancel"

        # Enter kill submap
        hyprctl dispatch submap kill
        ;;

    cancel)
        # Reset cursor to default
        hyprctl setcursor default 24

        # Show notification
        notify-send -u low -t 1000 "Kill Mode" "Cancelled"

        # Exit submap
        hyprctl dispatch submap reset
        ;;

    kill)
        # Get the window address under cursor
        WINDOW_INFO=$(hyprctl activewindow -j 2>/dev/null)
        ADDRESS=$(echo "$WINDOW_INFO" | jq -r '.address // empty')
        TITLE=$(echo "$WINDOW_INFO" | jq -r '.title // "Unknown"')

        if [ -n "$ADDRESS" ] && [ "$ADDRESS" != "0x0" ]; then
            # Kill the window cleanly
            hyprctl dispatch closewindow address:$ADDRESS
            notify-send -u low -t 1500 "✓ Window Closed" "$TITLE (clean)"
        else
            notify-send -u normal -t 1500 "Kill Mode" "No window under cursor"
        fi

        # Reset cursor
        hyprctl setcursor default 24

        # Exit submap
        hyprctl dispatch submap reset
        ;;

    force-kill)
        # Get the window PID under cursor
        WINDOW_INFO=$(hyprctl activewindow -j 2>/dev/null)
        PID=$(echo "$WINDOW_INFO" | jq -r '.pid // empty')
        TITLE=$(echo "$WINDOW_INFO" | jq -r '.title // "Unknown"')

        if [ -n "$PID" ] && [ "$PID" != "0" ]; then
            # Force kill the process with -9
            kill -9 "$PID"
            notify-send -u normal -t 1500 "💀 Process Force Killed" "$TITLE (PID: $PID)"
        else
            notify-send -u normal -t 1500 "Kill Mode" "No window under cursor"
        fi

        # Reset cursor
        hyprctl setcursor default 24

        # Exit submap
        hyprctl dispatch submap reset
        ;;

    *)
        echo "Usage: $0 {activate|cancel|kill}"
        exit 1
        ;;
esac
