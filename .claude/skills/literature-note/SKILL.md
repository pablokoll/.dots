---
name: literature-note
description: Active study session to take literature notes in the vault. Trigger on /literature-note or "let's take a literature note on X", "open a study session for X".
---

# literature-note

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`
Destination: `Resources/Inbox/<title in English>.md`

## Source types

| Type | How to read |
|------|-------------|
| URL / article / blog | `WebFetch` |
| PDF | `Read` tool |
| YouTube | user pastes transcript manually |

## Protocol

### 1. Receive source
- If source provided → read it by type
- If not → ask: "What's the source? (URL, PDF path, or paste the transcript)"
- If it fails → warn and ask user to paste content manually

### 2. Confirm title and author
- Suggest title from source, extract author if available
- Ask for confirmation or adjustment

### 3. Create empty note

```markdown
---
tags:
  - zettelkasten/literature
  - status/pending
author: <extracted or empty>
created: YYYY-MM-DD
sources:
  - <URL or [[Note name]]>
keywords:
  -
---

## 📘 <Title>

> [!NOTE] Main idea
> WRITE AT THE END

## ❓ Questions / Open Doubts

## 📌 Main Ideas

---
## ⚛️ Atomic note candidates
```

Confirm: `"Note created at Resources/Inbox/<title>.md — ready when you are."`

### 4. Active session loop
For each user message:
1. Verify idea against the source
2. If correct → add to note with Edit tool:
   - Ideas under `## 📌 Main Ideas` as `### 💡 Idea N`
   - Questions under `## ❓ Questions / Open Doubts`
3. If incorrect → flag the error with the source's exact wording, ask to correct before adding
4. If idea warrants an atomic note:
   - Search vault (including `aliases:` in frontmatter)
   - Exists → link `[[Note]]` inline + add `- [x] [[Note]]` in ⚛️ section
   - Doesn't exist → add `- [ ] [[Suggested Name]]` in ⚛️ section
5. Confirm briefly — max 3-4 lines depending on the concept, no filler

### 5. Close
When user says "done", "close", "wrap up":
1. Propose `keywords` (active recall triggers, not generic descriptors)
2. Propose **Main idea** (one Feynman sentence)
3. Wait for confirmation or adjustments
4. Update `keywords`, Main idea, and `modified:` in the note
5. Show final note path
6. List any `- [ ]` pending in ⚛️ section
7. Remind: `"Use /refine-notes to process atomic note candidates."`

## Rules
- Filename always in English
- User's words first — don't paraphrase in generic tone
- Always verify against source before adding
- Main idea written at the end, never at the start
- Don't move the note — stays in `Resources/Inbox/`
- Don't extract atomic notes — that's `/refine-notes`
- Match content language to user's language in session
