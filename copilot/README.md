# copilot/ — AI config for WSL Arch

Claude Code config ported to GitHub Copilot CLI. Lives on the `wsl` branch of
the dots repo.

## Full migration on a fresh WSL Arch

```bash
# 1. clone the dots bare repo
git clone --bare git@github.com:pablokoll/.dots.git ~/Work/personal/.dots
alias dots="git --git-dir=$HOME/Work/personal/.dots --work-tree=$HOME"
dots checkout wsl
dots config status.showUntrackedFiles no

# 2. packages, plugins, shell
~/copilot/bootstrap-wsl.sh

# 3. copilot config
~/copilot/install.sh

# 4. manual bits
#    tmux: prefix + I     (install plugins)
#    nvim: launch once    (lazy.nvim sync)
#    copilot: mise use -g copilot@latest && copilot   (then /login)
```

## Layout

| Path | What |
|---|---|
| `AGENTS.md` | Source of truth: caveman + ponytail + vault path + stack + commits |
| `skills/` | 23 skills, `SKILL.md` format identical to Claude Code |
| `skills/global-config/` | **Generated** by `install.sh` from `AGENTS.md` — don't edit by hand |
| `install.sh` | Regenerates `global-config`, copies skills to `~/.copilot/skills/` |
| `bootstrap-wsl.sh` | pacman packages, tpm, mise, default shell |

Edit `AGENTS.md`, re-run `install.sh`.

## Why global-config is a skill

Copilot CLI reads `AGENTS.md` only from the **git root or cwd** — there is no
global instructions file. Tested and confirmed non-working: `~/.copilot/AGENTS.md`,
`COPILOT_CUSTOM_INSTRUCTIONS_DIRS`, `--add-dir`. Skills in `~/.copilot/skills/`
*are* global, so `AGENTS.md` is wrapped as an always-on skill.

Verified: from an unrelated cwd, Copilot answered with the configured vault path
and commit format, and dropped its default `Co-authored-by` trailer.

For repos you work in daily, also drop `AGENTS.md` at the repo root — a real
instructions file beats a skill the model chooses to load.

## Claude Code → Copilot

| Claude Code | Copilot |
|---|---|
| `~/.claude/CLAUDE.md` | `AGENTS.md` (repo root) + `global-config` skill |
| `~/.claude/skills/<n>/SKILL.md` | `~/.copilot/skills/<n>/SKILL.md` — same format |
| `~/.claude/agents/*.md` | `.github/agents/*.md`, via `copilot --agent <name>` |
| `/skill-name` | `/skill-name` |
| hooks | **no equivalent** — behavior moved into `AGENTS.md` prose |
| `.claude/project-link.md` | `.github/project-link.md` |

## Known gaps

- **Hooks don't exist.** caveman/ponytail were deterministic plugins; now they
  ride in a skill the model chooses to load. Worked in testing, but it's
  probabilistic, not guaranteed.
- **Vault path** is `/mnt/c/Users/62010/Documents/Obsidian Vault/` — WSL
  crossing to the Windows filesystem. Slow for bulk reads; fine for notes.

## Not migrated

`omarchy`, `dots-sync`, `diagnose-crash` (Linux desktop only), `flashcards`,
`pk-brand`, `notebooklm` (needs `nlm` CLI + MCP).
