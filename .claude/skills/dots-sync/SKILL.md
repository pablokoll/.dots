---
name: dots-sync
description: Sync dotfiles to the .dots repo. Trigger on /dots-sync or "sync dotfiles", "push my configs", "dots sync".
---

# dots-sync

## Setup
- **Bare repo**: `~/Work/personal/.dots`
- **Alias**: `dots` = `git --git-dir=$HOME/Work/personal/.dots --work-tree=$HOME`
- **Remote**: `git@github.com:pablokoll/.dots.git`

## Protocol

1. Run `dots status` + `dots diff` — show changes grouped by tool (nvim, hypr, zsh, etc.)
2. Ask: what to include? anything to skip?
3. `dots add <confirmed files>` → `dots status` to verify staging
4. Suggest conventional commit message (`feat(nvim): ...`, `fix(hypr): ...`) — ask confirmation
5. `dots commit -m "<message>"` → `dots push`
6. Confirm: "Pushed to github.com/pablokoll/.dots"

## Never commit
`.ssh/config`, `.gitconfig`, `.claude/settings.json`, `.bak`/`.backup` files.
Warn if anything potentially sensitive appears (tokens, IPs, passwords).

## Tracked files (reference)

| Tool | Path |
|------|------|
| nvim | `~/.config/nvim/` |
| Ghostty | `~/.config/ghostty/` |
| Hyprland | `~/.config/hypr/` |
| waybar | `~/.config/waybar/` |
| walker | `~/.config/walker/` |
| mako | `~/.config/mako/` |
| alacritty | `~/.config/alacritty/` |
| kitty | `~/.config/kitty/` |
| tmux | `~/.config/tmux/tmux.conf` |
| zsh | `~/.zshrc` |
| starship | `~/.config/starship.toml` |
| Claude Code | `~/.claude/CLAUDE.md`, `~/.claude/skills/` |
| Zed | `~/.config/zed/settings.json`, `~/.config/zed/keymap.json`, `~/.config/zed/themes/` |
| VSCode | `~/.config/Code/User/settings.json`, `keybindings.json`, `snippets/`, `extensions.txt` |
| SSH (example) | `~/.ssh/config.example` |
| git | `~/.gitconfig.example` |
| Obsidian | `/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/.obsidian/`, `/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/.obsidian.vimrc` |
