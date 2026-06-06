---
name: notebooklm
description: >
  NotebookLM integration via `nlm` CLI. REQUIRED when user says "nlm", "nblm", "notebooklm",
  references a notebook by name, wants to process a PDF/video/URL into a research notebook,
  generate a podcast/audio from sources, query a notebook, or add Obsidian notes as notebook
  sources. Triggers: "agregá este PDF al notebook", "consultá el cuaderno de X",
  "generá un audio de", "creá un notebook para", "investigá en notebooklm".
  Excludes generic "sources" or "audio" without NLM context.
---

# NotebookLM Skill

Interact with Google NotebookLM via the `nlm` CLI. This skill is the single entry point
for all NotebookLM operations — never call `nlm` directly outside this skill.

**CLI Reference:** https://github.com/jacob-bd/notebooklm-mcp-cli/blob/main/docs/CLI_GUIDE.md
Fetch this URL when uncertain about command syntax or new features.

**If a command fails or behaves unexpectedly:** fetch the CLI_GUIDE.md URL above + check
https://github.com/jacob-bd/notebooklm-mcp-cli/commits/main for recent changes before
assuming user error or retrying. Syntax changes frequently.

## Installation (first time only)

```bash
uv tool install notebooklm-mcp-cli
nlm login          # browser-based Google auth
nlm login --check  # verify auth
```

Session expires ~20 min — re-run `nlm login` if commands fail with auth errors.

## Vault

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Intent → Action mapping

| User intent | nlm operation | Obsidian output |
|-------------|--------------|-----------------|
| Process PDF (study) | `source add --file` | `/literature-note` |
| Process PDF (project) | `source add --file` | `/project-log` |
| Process PDF (quick capture) | `source add --file` | `/quick-note` |
| Process URL/video | `source add --url` / `--youtube` | depends on context |
| Query a notebook | `notebook query` | optional `/quick-note` |
| Generate audio/podcast | `audio create` + `download audio` | optional save to vault |
| New notebook | `notebook create` + `alias set` | — |
| Research a topic | `research start --auto-import` | `/literature-note` or `/quick-note` |
| Batch query | `batch query` or `cross query` | — |

**When intent is ambiguous:** ask one question — "¿esto es para estudio, un proyecto, o captura rápida?"

## Decision Framework

1. **New notebook?** → `nlm notebook create` then `nlm alias set` for a short alias
2. **Target notebook unknown?** → ALWAYS run `nlm notebook list` and show the list to the user
   before proceeding. Ask: "¿en qué cuaderno lo metemos?" or suggest the most relevant one.
   Never assume a notebook without confirming.
3. **Adding source?**
   - PDF → `--file <path> --wait`
   - URL → `--url <url> --wait`
   - YouTube → `--youtube <url> --wait`
   - Obsidian note → export as `--text` (read file, pass content) or `--file` if PDF
3. **Querying?** → `nlm notebook query <alias> "question"` or `nlm cross query` for multi-notebook
4. **Generating content?** → `nlm audio create` / `nlm report create` / etc., then poll with `nlm studio status`, then `nlm download`
5. **Don't know notebook ID?** → `nlm notebook list` or `nlm alias list`
6. **Unsure about syntax?** → fetch CLI_GUIDE.md URL above

## Aliases

Always create an alias when creating a notebook — saves tokens on every subsequent call.

```bash
nlm alias set <short-name> <notebook-id>
# Then use: nlm notebook query <short-name> "..."
```

## Obsidian Integration

### Vault note → NotebookLM source

Read the note with the Read tool, then:
```bash
# As text source
nlm source add <notebook> --text "<content>" --title "<note title>" --wait

# If it's a PDF already in vault
nlm source add <notebook> --file "<vault-path>/file.pdf" --wait
```

### NotebookLM output → Vault note

After any query or content generation, offer to save output to vault.
Choose the right skill based on intent detected at invocation:

- **Study / learning material** → invoke `/literature-note` session with the output as source
- **Project-related** → invoke `/project-log` to append to the project index
- **Quick capture / reference** → invoke `/quick-note` to `Resources/Inbox/`

### NLM Frontmatter Convention

Every vault note linked to a NotebookLM notebook MUST include:

```yaml
notebook_id: <notebook-id>   # full UUID from `nlm notebook list --json`
tags:
  - nlm/<notebook-alias>     # e.g. nlm/ai-research
```

This enables:
- Filtering all vault notes sourced from a given notebook
- Navigating back to the notebook from any note
- Tracing what % of a note came from NLM

Apply this convention when creating or updating notes via `/quick-note`, `/literature-note`, or `/project-log` in the context of this skill. Pass `notebook_id` and the nlm tag to those skills as additional frontmatter.

## Commands Reference (compact)

## Output Handling

The CLI forces JSON output when stdout is not a TTY (i.e. always when run from Claude Code).
**Always pipe query output through python to extract the answer:**

```bash
nlm notebook query <alias> "question" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['value']['answer'])"
```

For `notebook describe` and `source describe`, extract similarly from the JSON response.
Never show raw JSON to the user.

## Commands Reference (compact)

### Notebooks
```bash
nlm notebook list
nlm notebook create "Title"
nlm notebook query <id|alias> "question"
nlm notebook describe <id|alias>
nlm notebook rename <id|alias> "New Title"
nlm notebook delete <id|alias> --confirm
```

### Sources
```bash
nlm source list <notebook>
nlm source add <notebook> --url <url> --wait
nlm source add <notebook> --file <path> --wait
nlm source add <notebook> --text "content" --title "Title"
nlm source add <notebook> --youtube <url> --wait
nlm source describe <source-id>
nlm source delete <source-id> --confirm
```

### Studio (content generation)
```bash
# Audio podcast
nlm audio create <notebook> --format deep_dive --length long --confirm
# Formats: deep_dive | brief | critique | debate
# Lengths: short | default | long

# Reports
nlm report create <notebook> --format "Briefing Doc" --confirm
# Formats: "Briefing Doc" | "Study Guide" | "Blog Post"

# Other
nlm quiz create <notebook> --count 10 --difficulty medium --confirm
nlm flashcards create <notebook> --confirm
nlm mindmap create <notebook> --confirm
nlm slides create <notebook> --confirm

# Check status
nlm studio status <notebook>
```

### Downloads
```bash
nlm download audio <notebook> <artifact-id> --output podcast.mp3
nlm download report <notebook> <artifact-id> --output report.md
nlm download flashcards <notebook> <artifact-id> --format markdown --output cards.md
```

### Research
```bash
nlm research start "query" --notebook-id <id> --mode deep --auto-import
nlm research status <notebook> --max-wait 300
```

### Batch / Cross
```bash
nlm batch query "question" --notebooks "id1,id2"
nlm cross query "question" --all
nlm batch add-source --url <url> --notebooks "id1,id2"
```

### Aliases
```bash
nlm alias set <name> <notebook-id>
nlm alias list
nlm alias delete <name>
```

### Tags (CLI tags, not Obsidian tags)
```bash
nlm tag add <notebook> --tags "ai,research"
nlm tag list
nlm tag select "ai research"
```

### Pipelines
```bash
nlm pipeline list
nlm pipeline run <notebook> ingest-and-podcast --url <url>
nlm pipeline run <notebook> research-and-report --url <url>
nlm pipeline run <notebook> multi-format
```

### Auth & Config
```bash
nlm login
nlm login --check
nlm login --profile work
nlm config show
nlm doctor
```

## Tips

- `--wait` on `source add` → ensures source is ready before querying
- Audio/video takes 1–5 min → poll with `nlm studio status`
- Use `nlm doctor` for auth/install issues
- `--json` flag on any list command for machine-readable output
- Short IDs shown by default; use `--full` to get full UUIDs when needed for `notebook_id` frontmatter
