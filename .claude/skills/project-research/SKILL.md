---
name: project-research
description: Collaborative research session between Claude and the user. Claude does web searches and brings findings; user handles internal context, business knowledge, private systems, and inaccessible sources. Together they build a living research note saved in the vault. Trigger on /project-research, /project-research <topic>, "investigamos X", "hagamos un research de", "arrancamos una investigación sobre", "necesito researchar", or whenever the user wants to do structured research on a topic before analysis or decision-making.
---

# project-research

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Purpose
A joint research session. Claude and the user each contribute what they can access. Claude handles web searches and synthesis; the user handles internal context, prior decisions, business knowledge, and anything behind a login. The output is a living research note designed to feed a future analysis note.

## Setup

### 1. Determine topic
- If argument provided: use it as the topic.
- If no argument: ask "What are we researching?"

### 2. Find the vault destination
- Check `.claude/project-link.md` in current dir.
  - If found: read `vault_path`, derive the project folder (parent dir of the Index file), save note to `<vault_root>/<project_folder>/researches/<topic-slug>.md`
  - If not found: save to `<vault_root>/Resources/Research/<topic-slug>.md`
- Filename format: `YYYY-MM-DD - <topic-slug>.md` (e.g. `2026-06-03 - oauth-autenticacion.md`)
- `topic-slug`: lowercase, hyphens, no spaces (e.g. "oauth-autenticacion", "stack-de-pagos")

### 3. Create the research note
Write the file immediately before starting the first research round:

```markdown
---
topic: <topic>
date: <YYYY-MM-DD>
status: in-progress
tags:
  - research
---

# Research: <topic>

## 🔍 Your Turn
<!-- Tasks assigned to you — context Claude can't access -->

## 📋 Research Log
<!-- Findings consolidated across all rounds -->
```

Tell the user: "Note created at `<path>`. Starting first round."

---

## Session Loop

Each round follows this sequence:

### Claude's turn
1. Do relevant web searches. Surface key findings — share them in conversation, explain what's useful and why.
2. Identify what's missing that only the user can provide: internal context, business decisions, prior conversations, private systems, team knowledge, undocumented constraints.
3. Update the research note:
   - Add findings to `## 📋 Research Log` (synthesized, not a raw dump — remove what's no longer relevant, consolidate what's clear)
   - Replace `## 🔍 Your Turn` with a fresh checklist of up to 5 prioritized tasks
4. Tell the user: "Note updated. Your tasks are in `## 🔍 Your Turn`. Share answers here when ready."

### User's turn
The user returns with answers, findings, or context.

### Claude processes user input
1. Read the current note.
2. Synthesize the user's answers into `## 📋 Research Log` — integrate, don't append raw.
3. Mark tasks as done (remove from Your Turn or mark ✅).
4. Assess: is the research sufficient? If not, add new tasks and continue. If yes, propose closing.

---

## Closing the Research

When both agree the research is complete (or Claude judges coverage is good enough):

1. Update frontmatter: `status: complete`
2. Add `## Summary` **below the frontmatter, before the Research Log**:
   ```markdown
   ## Summary
   - Key finding 1
   - Key finding 2
   - Key finding 3
   ```
3. Add `## Next Steps` at the bottom:
   ```markdown
   ## Next Steps
   <!-- What a future analysis note should cover -->
   - ...
   ```
4. Tell the user: "Research complete. Note saved at `<path>`, ready to use as analysis input. Continue with `/project-analysis` or work the note manually."

---

## Rules

- **Web searches** → Claude does them. Share findings conversationally, then log them.
- **Internal/private context** → user's responsibility. Assign via Your Turn checklist.
- **Max 5 tasks in Your Turn at once** — prioritize ruthlessly, don't overwhelm.
- **Every round ends with the file updated on disk** — the note is always current.
- **Research Log stays synthesized** — not a raw append log. Rewrite sections as understanding improves.
- **Output language follows active session language. Default: English.**
- **Don't close prematurely** — if there are open tasks or unresolved questions, keep going.
- **Don't loop infinitely** — after 5+ rounds, surface a "Continue or close?" check.
