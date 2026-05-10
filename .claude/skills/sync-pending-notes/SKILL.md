---
name: sync-pending-notes
description: Bidirectional sync of pending tasks between daily notes and Core.md. Trigger on /sync-pending-notes or "sync my pendings", "update Core", "show my pending tasks".
---

# sync-pending-notes

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## What it does
Bidirectional sync between daily notes and `Area/Core.md`:
1. **Propagate completions first**: find `- [x]` tasks in Core.md Pendings block → mark them done in their origin daily note
2. **Extract pending tasks**: scan last 30 days of daily notes → collect `- [ ]` with real text
3. **Update Core.md**: replace the Pendings block with fresh data

## Protocol

1. Read `Area/Core.md` — extract `## 🎯 Pendings` block
2. For each `- [x]` task found, mark it complete in `Area/Journal/<date>.md`
3. Glob `Area/Journal/????-??-??.md` — filter last 30 days, newest first
4. Extract `- [ ] <text>` lines with real content
5. Build new Pendings block and replace in Core.md
6. Confirm: "X tasks marked complete. Pendings updated: N dates, N tasks."

## Pendings block format

```markdown
## 🎯 Pendings

> Updated: YYYY-MM-DD HH:MM

### YYYY-MM-DD
- [ ] <task>

### YYYY-MM-DD
- [ ] <task>
```

## Rules
- Propagate completions BEFORE extracting — order matters
- Skip tasks containing `Habitica Tracker` or `Exercise`
- Only include tasks with real text after `- [ ]`
- If no pendings found: write `> No recent pending tasks.`
- Don't touch any other section in Core.md or daily notes
