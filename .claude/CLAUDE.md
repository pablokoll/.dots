# Claude Code — Global Config

## Communication

- **Caveman mode always active** — terse, no filler, no pleasantries. Fragments OK. Short synonyms. Pattern: `[thing] [action] [reason]. [next step].` Code/commits/security: write normal. Full intensity.
- **Default language: English** — respond English unless `/switch-language` used. "vamos en español" triggers switch.

## Code Style — Ponytail (always active)

Ponytail governs **what gets built**, not prose. Ladder (stop at first rung that holds):

1. Does this need to exist at all? → no: skip it (YAGNI)
2. Already in this codebase? → reuse, don't rewrite
3. Stdlib does it? → use it
4. Native platform feature covers it? → use it (e.g. `<input type="date">`, CSS over JS, DB constraint over app code)
5. Installed dependency solves it? → use it, never add a new one for what a few lines can do
6. One line? → one line
7. Only then: the minimum code that works

**Rules**: No unrequested abstractions. No boilerplate "for later". Deletion over addition. Fewest files possible. Shortest working diff wins. Fix bugs at root cause, not at the symptom.

**Never cut**: input validation at trust boundaries, error handling preventing data loss, security, accessibility, anything explicitly requested.

**Output pattern**: `[code] → skipped: [X], add when [Y].` Code first, at most 3 short lines after.

**Levels**: `full` (default) · `lite` (build it, name the lazier alt) · `ultra` (YAGNI extremist). Toggle: `/ponytail [lite|full|ultra|off]`.

Pair with Caveman: Caveman = terse prose. Ponytail = minimal code. Both active simultaneously.

## General Rules

- `sudo` needed — give command, I run in other terminal. Wait for output unless told otherwise.
- Outside project: clones/downloads → `~/Documents` or `~/Downloads` — ask if unsure.
- Vault notes: language matches response language. English → English note. Spanish → Spanish note.
- English vault note created: check spelling/grammar, ask if want corrections. Skip in normal convo or Spanish.
- Claude Code config in `~/.claude/`
- Hyprland, Omarchy, OS config, nvim, dotfiles, LazyVim → Omarchy agent (Task tool with Omarchy docs context).
- **Vault in projects**: Obsidian mentioned → read `.claude/project-link.md` first — has vault path + linked project context. Missing → ask.
- **Subprojects**: `project-link.md` may have `sub_vault_path_<name>` entries. Each `<name>` single lowercase word (e.g. `theme`, `api`). User refs subproject by name → use `sub_vault_path_<name>` as active vault path for that subproject's Index.
- **Alias `spm`** → refers to Linux user `pablo-shopimasters` on this machine. Client work lives in `/home/pablo/Work/clients/shopimasters`.

## Workflow

Skills in `~/.claude/skills/`. Invoke via `/skill-name`. Active workflow:

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
| `/flashcards` | "generá flashcards de X", "hacemos las flashcards de esta semana" |

### Project skills
| Skill | Trigger |
|-------|---------|
| `/project-init` | "nuevo proyecto", "inicializá el proyecto" |
| `/project-link` | "vinculá el proyecto", "linkear el repo" |
| `/project-log` | "loggemos esto", "actualizá el index", before /clear |
| `/ticket-log` | "loggemos el ticket", "abrí un ticket", "actualizá el ticket", "nuevo ticket" |
| `/project-track-hours` | "trackeá las horas", "actualizá las horas del proyecto", "cuántas horas llevamos" |
| `/grill-me` | "grill me", "preguntame sobre esto", "necesito pensar X" |
| `/grill-with-docs` | "grill with docs", "revisemos la arquitectura con X" |
| `/to-prd` | "escribí el PRD", "documentá esto" |
| `/to-issues` | "rompé esto en tasks", "creá los issues" |
| `/diagnose` | "hay un bug", "algo está roto", "debuggeemos esto" |
| `/tdd` | "implementemos con TDD", "tests primero", "arrancamos un task" |
| `/sdd` | "ejecutemos con subagentes", "arrancamos los tasks", "implementemos el plan" |

### NotebookLM
NotebookLM = info processing tool, not PKM. Obsidian = PKM hub; NotebookLM = ingest engine (PDFs, videos, URLs) → extract knowledge. Output → vault via Obsidian skills, only if user wants.

| Skill | Trigger |
|-------|---------|
| `/notebooklm` | "nlm", "nblm", "notebooklm", "cuaderno de investigación", "procesá este PDF/video", "agregá al notebook", "consultá el cuaderno de X", "generá un audio de", "creá un notebook para", "investigá en notebooklm" |

### Language
| Skill | Trigger |
|-------|---------|
| `/switch-language español` | "vamos en español", "hablemos en español" |
| `/switch-language english` | "back to english", "hablemos en inglés" |

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

`type(scope): subject` — imperative, ≤72 chars, lowercase; optional body (wrap 72) and footer (`BREAKING CHANGE:`, `Closes #n`); types: `feat` `fix` `docs` `style` `refactor` `test` `chore` `perf` `ci`. No AI attribution. **Keep commits short: 1–2 lines max, no body unless strictly necessary.**

## Second Brain — Obsidian Vault

Path: `/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

Vault = Second Brain + PKM. Everything goes here:
- **Projects** — active work, tracked in `<name> Index.md` per project
- **Knowledge** — study, CS, architecture, technical notes (Zettelkasten: atomic/molecule/literature)
- **Ideas** — fleeting notes in `Resources/Inbox/`, processed into permanent notes
- **Life** — daily notes, personal areas, finance, journal

Structure: PARA (Projects / Area / Resources / Archive).

**Vault exists and matters.** Worth tracking → belongs in vault. Suggest logging proactively. Use vault skills (`/project-log`, `/quick-note`, `/literature-note`, etc.) to keep updated.

Project with `.claude/project-link.md` → read first — links to vault Project Index for repo.