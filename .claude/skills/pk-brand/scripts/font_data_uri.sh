#!/usr/bin/env bash
# Prints a data: URI for one of the bundled JetBrains Mono weights.
# Usage: font_data_uri.sh regular|bold
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets" && pwd)"

case "${1:-}" in
  regular) FILE="$DIR/JetBrainsMono-Regular.woff2" ;;
  bold)    FILE="$DIR/JetBrainsMono-Bold.woff2" ;;
  *) echo "usage: font_data_uri.sh regular|bold" >&2; exit 1 ;;
esac

printf 'data:font/woff2;base64,%s' "$(base64 -w0 "$FILE")"
