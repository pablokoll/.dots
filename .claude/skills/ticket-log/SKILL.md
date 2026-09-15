---
name: ticket-log
description: Create or update a ticket note in the vault. Tracks work sessions, tasks, hours, and notes per ticket. Trigger on /ticket-log, "loggemos el ticket", "abrí un ticket", "actualizá el ticket".
---

# ticket-log

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocol

### 1. Find the Project Index
- Check `.claude/project-link.md` → read `vault_path`
- Derive project folder: parent dir of `vault_path`
- Tickets live at `<project_folder>/tickets/`

### 2. Ask for ticket info (one question at a time)
Ask only what you don't already have from the user's message:
1. **Ticket ID** — "Ticket ID? (e.g. BLMSHPF-1234)"
2. **Ticket name** — "Ticket name?"

Then check if `tickets/BLMSHPF-XXXX - <name>.md` already exists:
- **Exists** → load it, go to step 4
- **Doesn't exist** → go to step 3

### 3. Create new ticket (ask one at a time)
3a. **Description** — "Original ticket description?"
3b. **Status** — "Status? (backlog / in-progress / qa-pending / pending-deploy / deployed / blocked)" — default: `backlog`
3c. **Importants** — "Anything important to note? (callout IMPORTANT, Enter to skip)"
3d. **Tasks** — "Initial tasks? (list, Enter to skip)"
3e. **Branch name** — Suggest a branch name derived from the ticket ID and title: `fix/BLMSHPF-XXXX-short-description` (use `fix/` for bugs, `feat/` for features, `chore/` for tasks). Ask: "Branch name? (suggested: `fix/BLMSHPF-XXXX-short-description`, Enter to accept)"
- Accept user input or confirmed suggestion as `branch` value
- If user skips (empty), leave `branch: ""` in frontmatter

Create `tickets/<ID> - <name>.md` with the template below.

### 4. Log a work session
Ask:
4a. **Hours** — "How many hours this session?"
4b. **Summary** — "What was done?"
4c. **Notes** — "Any notes to save? (Enter to skip)"
4d. **Updated tasks** — "Any tasks to mark complete or add?"

Append session entry to `## Work Log`. Update `total_hours` in frontmatter (sum previous + new). Update `modified:`.

If user only wants to **update tasks or notes** without logging a session, skip 4a/4b and only apply the relevant change.

If user updates the status (e.g. "pasalo a deployed"), update `status:` in frontmatter directly — no session log needed.

### 5. Update Project Index
- Glob `<project_folder>/tickets/` for all `.md` files
- Replace or create `## 🎫 Tickets` section in Index with links to each ticket, reading `status:` from each ticket's frontmatter:
  ```markdown
  ## 🎫 Tickets
  - [[tickets/BLMSHPF-XXXX - Nombre]] · `pending-deploy`
  ```
  Valid statuses: `backlog` · `in-progress` · `qa-pending` · `pending-deploy` · `deployed` · `blocked`
- Update `modified:` in Index frontmatter

### 6. Confirm
"Ticket [[tickets/<ID> - <name>]] updated. Total: <N>hs."

After confirming, add one line: "Run `/project-track-hours` to update the monthly hours log."

### 7. Branch setup (new tickets only, or if ticket has a branch name set)
Ask: "Create branch `<branch>`? (checkout main + pull + new branch)"
- **Yes** → run in sequence:
  ```
  git checkout main
  git pull origin main
  git checkout -b <branch>
  ```
  Confirm: "Branch `<branch>` ready."
- **No / skip** → do nothing

---

## Ticket file template (new tickets)

```markdown
---
tags:
  - project/ticket
project: <project_name>
ticket: <ID>
status: backlog
branch: <branch_name>
created: YYYY-MM-DD
modified: YYYY-MM-DD
total_hours: 0
---

# <ID> — <name>

## Description
<original description>

> [!IMPORTANT]
> <importants or remove callout if none>

## Tasks
- [ ] <task or remove section if none>

## Notes
<!-- personal notes -->

## Work Log
```

---

## Rules
- Output language follows active session language. Default: English.
- Never auto-infer ticket ID or name — always ask the user
- One question at a time
- If user provides everything upfront, process directly without asking
- Don't touch `## ✅ TODO` or `## 🔑 ADR's` in the Index
- `## 🎫 Tickets` in Index is always regenerated from the actual files in `tickets/`
- If `tickets/` folder doesn't exist in the vault project folder, create it silently
