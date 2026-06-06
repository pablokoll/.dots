# Claude Code — Global Config

## Communication

- **Caveman mode always active** — terse, no filler, no pleasantries. Fragments OK. Short synonyms. Pattern: `[thing] [action] [reason]. [next step].` Code/commits/security: write normal. Full intensity.

## General Rules

- Anything requiring `sudo` — give me the command, I run it in another terminal. Wait for me to share output before continuing, unless I say otherwise.
- Outside a project: clone repos or downloads go to `~/Documents` or `~/Downloads` — ask if unsure which.
- When creating vault notes (daily note, quick note, etc.): note language must match my response language. English answers → English note. Spanish answers → Spanish note.
- If I replied in English when creating a vault note: check spelling/grammar at the end and ask if I want corrections. Skip this in normal conversation or Spanish.
- Claude Code config lives in `~/.claude/`
- Hyprland, Omarchy, OS config, nvim, dotfiles, LazyVim → use the Omarchy agent (Task tool with Omarchy docs context).
- **Vault in projects**: if I mention Obsidian while in a project, read `.claude/project-link.md` first — it has the vault path and linked project context. If missing, ask.
- **Subprojects**: `project-link.md` may contain `sub_vault_path_<name>` entries for subprojects. Each `<name>` is a single lowercase word (e.g. `theme`, `api`). When the user says "trabajemos en sub `theme`" or references a subproject by name, use that `sub_vault_path_<name>` as the active vault path for that subproject's Index.

## Workflow

Skills live in `~/.claude/skills/`. Invoke via `/skill-name`. The active workflow:

```
grill-me | grill-with-docs → to-prd → to-issues → sdd (+tdd +diagnose) → project-log
```

### Vault skills
| Skill | Trigger |
|-------|---------|
| `/daily-note` | "daily note", "registremos el día" |
| `/quick-note` | "anotá esto", "quiero guardar una idea" |
| `/sync-pending-notes` | "sincronizá los pendings" |
| `/refine-notes` | "refinemos esta nota", "saquemos atomic notes" |
| `/literature-note` | "literature note de X", "sesión de estudio" |
| `/review-vault` | "revisemos el vault", "auditoría del vault" |
| `/zoom-out` | "zoom out", "revisión estratégica" |

### Project skills
| Skill | Trigger |
|-------|---------|
| `/project-init` | "nuevo proyecto", "inicializá el proyecto" |
| `/project-link` | "vinculá el proyecto", "linkear el repo" |
| `/project-log` | "loggemos esto", "actualizá el index", before /clear |
| `/grill-me` | "grill me", "preguntame sobre esto", "necesito pensar X" |
| `/grill-with-docs` | "grill with docs", "revisemos la arquitectura con X" |
| `/to-prd` | "escribí el PRD", "documentá esto" |
| `/to-issues` | "rompé esto en tasks", "creá los issues" |
| `/diagnose` | "hay un bug", "algo está roto", "debuggeemos esto" |
| `/tdd` | "implementemos con TDD", "tests primero", "arrancamos un task" |
| `/sdd` | "ejecutemos con subagentes", "arrancamos los tasks", "implementemos el plan" |

### NotebookLM
NotebookLM es una herramienta de procesamiento de información del ecosistema — no un PKM.
Obsidian es el central de PKM; NotebookLM es el motor para ingerir fuentes (PDFs, videos, URLs)
y extraer conocimiento de ellas. El output puede volver al vault via las skills de Obsidian — solo si el usuario lo quiere.

| Skill | Trigger |
|-------|---------|
| `/notebooklm` | "nlm", "nblm", "notebooklm", "cuaderno de investigación", "procesá este PDF/video", "agregá al notebook", "consultá el cuaderno de X", "generá un audio de", "creá un notebook para", "investigá en notebooklm" |

### Dots
| Skill | Trigger |
|-------|---------|
| `/dots-sync` | "sincronizá los dotfiles", "backup config" |

## Stack & Preferences

### JS/TS
- Frontend: React, Next.js, Vite · Tailwind CSS, shadcn/ui · Zustand · React Query
- Backend: Express.js, NestJS · Prisma ORM · tRPC
- DB: PostgreSQL (preferred) · MongoDB · Redis
- Testing: Vitest/Jest · Playwright · Testing Library
- Tools: ESLint + Prettier (or Biome) · Husky · pnpm
- Infra: Docker Compose · GitHub Actions

### Code Conventions
- Variables/functions: `camelCase`
- React components: `PascalCase`
- Files: `kebab-case`
- Constants: `UPPER_SNAKE_CASE`
- Directories: `kebab-case`

### Design Principles
SOLID · Clean Architecture (when it fits) · DRY · KISS · YAGNI · Separation of Concerns

## Commits

Conventional commits: `type(scope): description`

Types: `feat` `fix` `docs` `style` `refactor` `test` `chore` `perf` `ci`

Never add `Co-Authored-By` or any AI attribution to commits.

## Second Brain — Obsidian Vault

Path: `/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

This vault is my Second Brain and PKM (Personal Knowledge Management) system. Everything goes here:
- **Projects** — all active work, tracked in `<name> Index.md` per project
- **Knowledge** — study, CS, architecture, technical notes (Zettelkasten: atomic/molecule/literature)
- **Ideas** — captured as fleeting notes in `Resources/Inbox/`, processed into permanent notes
- **Life** — daily notes, personal areas, finance, journal

Structure: PARA (Projects / Area / Resources / Archive).

**Always assume the vault exists and matters.** If something is worth tracking — a project, a decision, a piece of knowledge, a study session — it belongs in the vault. Proactively suggest logging or noting when relevant. Use vault skills (`/project-log`, `/quick-note`, `/literature-note`, etc.) to keep it up to date.

When in a project with `.claude/project-link.md`: read it first — it links to the vault Project Index for that repo.
