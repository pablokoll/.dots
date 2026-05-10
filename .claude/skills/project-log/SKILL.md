---
name: project-log
description: Log work done in a project to the vault Project Index. Trigger on /project-log, "log the work", "update the project index", or before /clear in a session with an active project.
---

# project-log

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocol

### 1. Find the Project Index
- Check `.claude/project-link.md` in current dir → read `vault_path`
- If not found, search vault for `*Index.md` with tag `project/index` matching current repo
- If still not found, ask the user or suggest `/project-init` / `/project-link`

### 2. Read git context (silent)
If `.git` exists in current dir:
```bash
git log --oneline -5
git diff --stat HEAD
git status --short
```
Build a draft from commits and changed files. If no git or clean repo, skip and ask directly.

### 3. Guided conversation (one question at a time)
Show draft and confirm:
1. **Summary** — "Based on the commits: `<draft>`. Adjust?"
2. **Files touched** — "Detected: `<list>`. Anything to add or remove?"
3. **Decisions** — "Any important decision to document? ('none' to skip)"
4. **Diagnose output** — if `/diagnose` was used in this session, ask: "Include the bug diagnosis? (root cause, fix, post-mortem)" — if yes, add a `## 🐛 Bug diagnosed` block to the session file
5. **Next steps** — "What are the next steps?"

### 4. Check for existing session
Glob `<project>/sessions/` for existing files. If found, show most recent and ask: continue that session or create new one?

### 5. Write Work Log entry
Append to `## 📋 Work Log` in the Project Index:

```markdown
### YYYY-MM-DD (~<time>)
**Summary:** <summary>
**Files:** <list>
**Decisions:** <decisions or —>
**Next steps:** <next steps or —>
**Session:** [[sessions/YYYY-MM-DD - <name>]]
```

### 6. Create or update session file
- **New session**: suggest name (3-5 words from commits/summary), confirm, create `sessions/YYYY-MM-DD - <name>.md`
- **Existing session**: append new content with `---` separator and timestamp

Session file format:
```markdown
---
tags:
  - project/session
project: <name>
created: YYYY-MM-DD
modified: YYYY-MM-DD
---

# Session YYYY-MM-DD — <name>

## Goal
<inferred and confirmed>

## What was done
<steps, decisions, key details>

## 🐛 Bug diagnosed (if applicable)
**Root cause:** <what caused it>
**Fix:** <what was done>
**Post-mortem:** <what would have prevented it>

## Status
<what's complete, what's pending>

## Next steps
<list>
```

### 7. Regenerate Related Files
Glob project folder → replace `## 📁 Related Files` in Index with list of all `.md` files except the Index itself.

### 8. Update `modified:` in Index frontmatter.

### 9. Confirm
"Logged in [[<name> Index]]. Entry for <date> added (~<time> worked)."

## Before /clear or /compact
If a Project Index is linked, ask: "Before clearing — log this session to the Project Index?"

## Rules
- Read git context before asking — questions are confirmation, not starting point
- One question at a time
- If user gives everything at once, process directly
- Don't touch `## ✅ TODO` or `## 🔑 ADR's` — those are manual
- `## 📁 Related Files` always regenerated automatically
