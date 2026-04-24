---
name: dots-sync
description: Sincronizar dotfiles al repo .dots. Invocá con /dots-sync o cuando el usuario diga "sincronizá los dotfiles", "subí los cambios de configs", "dots sync", o frases similares indicando querer versionar cambios en configuraciones del sistema.
---

# dots-sync — Sincronizar Dotfiles

## Setup

- **Repo bare**: `~/Work/personal/.dots`
- **Alias**: `dots` (equivale a `git --git-dir=$HOME/Work/personal/.dots --work-tree=$HOME`)
- **Remote**: `git@github.com:pablokoll/.dots.git`

## Protocolo

### Paso 1: Mostrar cambios

Ejecutá:
```bash
dots status
dots diff
```

Presentá al usuario un resumen agrupado por herramienta:
- **nvim**: archivos modificados
- **hypr**: archivos modificados
- **zsh / ghostty / tmux / etc.**

Mostrá el diff de cada archivo modificado para que el usuario pueda revisarlo.

### Paso 2: Decidir qué subir

Preguntá al usuario:
- ¿Qué archivos/grupos querés incluir en este commit?
- ¿Hay algo que NO querés subir?

Si hay archivos nuevos no trackeados relevantes (configs nuevas), preguntá si los agrega.

### Paso 3: Armar el commit

Una vez confirmado qué va:
```bash
dots add <archivos confirmados>
dots status  # verificar staging
```

Sugerí un mensaje de commit en formato conventional commits:
- `feat(nvim): ...`
- `fix(hypr): ...`
- `chore(zsh): ...`
- `style(waybar): ...`

Pedí confirmación del mensaje antes de commitear.

### Paso 4: Commit y push

```bash
dots commit -m "<mensaje confirmado>"
dots push
```

Confirmá con: "Pusheado a github.com/pablokoll/.dots ✓"

## Reglas

- Nunca subir: `.ssh/config`, `.claude/settings.json`, archivos `.bak` o `.backup`
- Si aparece algo potencialmente sensible (tokens, IPs, passwords), avisá antes de continuar
- El `.gitignore` en `~/` ya excluye los archivos sensibles conocidos — confiar en él
- Plugins de TPM y lazy.nvim no se trackean — ignorar cambios en `~/.config/tmux/plugins/` y `~/.local/share/nvim/`

## Archivos trackeados (referencia)

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
| git | `~/.gitconfig` |
| starship | `~/.config/starship.toml` |
| Claude Code | `~/.claude/CLAUDE.md` |
| SSH (example) | `~/.ssh/config.example` |
