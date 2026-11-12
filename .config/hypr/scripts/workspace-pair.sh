#!/bin/bash
# Switch a workspace pair: odd N shows with N+1, even N with N-1, ending focused
# on the one asked for. Monitor-agnostic: each workspace's rule (monitors.lua,
# lid-workspace-follow.sh) decides where it shows.

WORKSPACE=$1
if (( WORKSPACE % 2 )); then PAIR=$((WORKSPACE + 1)); else PAIR=$((WORKSPACE - 1)); fi

hyprctl dispatch "hl.dsp.focus({ workspace = \"$PAIR\" })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ workspace = \"$WORKSPACE\" })" >/dev/null
