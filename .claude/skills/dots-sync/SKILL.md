---
name: dots-sync
description: Sincronizar dotfiles al repo .dots. Invocá con /dots-sync o cuando el usuario diga "sincronizá los dotfiles", "subí los cambios de configs", "dots sync", o frases similares indicando querer versionar cambios en configuraciones del sistema.
---

# dots-sync — Sincronizar Dotfiles

## Setup

- **Repo bare**: `~/Work/personal/.dots`
- **Alias**: `dots` (equivale a `git --git-dir=$HOME/Work/personal/.dots --work-tree=$HOME`)
- **Remote**: `git@github.com:pablokoll/.dots.git`

## Setup en máquina nueva

```bash
# 1. Clonar el repo bare
git clone --bare git@github.com:pablokoll/.dots.git $HOME/Work/personal/.dots

# 2. Agregar el alias
echo 'alias dots="git --git-dir=$HOME/Work/personal/.dots --work-tree=$HOME"' >> ~/.zshrc
source ~/.zshrc

# 3. Ocultar untracked files
dots config status.showUntrackedFiles no

# 4. Checkout (si hay conflictos, hacer backup primero)
dots checkout
# Si hay conflictos:
# mkdir -p ~/.dots-backup
# dots checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I{} mv {} ~/.dots-backup/{}
# dots checkout
```

### VSCode — instalar extensiones

```bash
cat ~/.config/Code/User/extensions.txt | xargs -L1 code --install-extension
```

### tmux — instalar plugins

Abrir tmux y presionar `prefix + I` (TPM descarga todos los plugins definidos en `tmux.conf`).

---

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

- Nunca subir: `.ssh/config`, `.gitconfig`, `.claude/settings.json`, archivos `.bak` o `.backup`
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
| git | `~/.gitconfig.example` (real `.gitconfig` excluded) |
| starship | `~/.config/starship.toml` |
| Claude Code | `~/.claude/CLAUDE.md` |
| Claude Skills | `~/.claude/skills/` |
| VSCode | `~/.config/Code/User/settings.json`, `keybindings.json`, `snippets/`, `extensions.txt` |
| SSH (example) | `~/.ssh/config.example` |
