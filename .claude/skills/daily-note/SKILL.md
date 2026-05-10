---
name: daily-note
description: Create today's daily note in the Obsidian vault. Trigger on /daily-note or phrases like "let's do the daily note", "log my day", "write my journal".
---

# daily-note

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`
Destination: `Area/Journal/YYYY-MM-DD.md`

## Protocol

1. Check if today's note exists. If yes, ask: overwrite or append?
2. Ask one question at a time, in order:
   - Mood: Very Bad / Bad / Normal / Good / Excellent
   - Energy: 1–5
   - What happened today?
   - What did you do? (tasks, study, exercise)
   - How do you feel now?
   - Anything for tomorrow?
3. Respect skips. If user says "create it", build with what's there.
4. Create the file. Confirm with path + one-line summary.

## File format

```markdown
---
id: YYYY-MM-DD
tags:
  - daily/note
created: YYYY-MM-DDThh:mm+01:00
modified: YYYY-MM-DDThh:mm+01:00
energy: <1-5>
mood: <very bad|bad|normal|good|excellent>
---

## 📝 Notes
- <user's words>

---
## ✅ What I did today
- Topic studied: <topic or "">
  - Time spent: ~__ min
- Tasks:
  - <tasks>
- [ ] Exercise (or [x] Exercise - <type> if done)
- [ ] Habitica Tracker

---
## 🫀 How I feel
- <user's words>

---
## 🔁 For tomorrow
- [ ] <task or reminder>
```

## Rules
- User's own words in content — no generic rewrites
- One question at a time
- If user dumps everything at once, process and create directly
- No extra sections beyond the template
- If user references a file with `@name` or `[[name]]`, include it as `[[name]]` (Obsidian link)
