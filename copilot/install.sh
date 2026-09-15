#!/usr/bin/env bash
# Install Copilot CLI config (WSL / Arch).
# Usage:  ~/copilot/install.sh
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="${COPILOT_HOME:-$HOME/.copilot}"

mkdir -p "$dst"

# AGENTS.md is the single source of truth. Copilot has no global instructions
# file -- it only reads AGENTS.md from the git root / cwd. Skills in
# ~/.copilot/skills/ ARE loaded globally, so wrap AGENTS.md as an always-on
# skill to get the same effect everywhere.
mkdir -p "$src/skills/global-config"
{
  cat <<'EOF'
---
name: global-config
description: Pablo's global working preferences — communication style (caveman), code style (ponytail), vault path, commit format, stack conventions, and the skill workflow. Load at the START of EVERY session, before any other work, regardless of the task. Always applicable.
---

EOF
  cat "$src/AGENTS.md"
} > "$src/skills/global-config/SKILL.md"

# Replace wholesale so skills deleted upstream don't linger.
rm -rf "$dst/skills"
cp -r "$src/skills" "$dst/skills"

echo "installed: $(find "$dst/skills" -maxdepth 1 -mindepth 1 -type d | wc -l) skills -> $dst/skills"
echo "per-repo:  cp $src/AGENTS.md <repo-root>/  for stronger adherence"
