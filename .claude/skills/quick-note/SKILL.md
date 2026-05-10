---
name: quick-note
description: Capture a fleeting note in the Obsidian vault. Trigger on /quick-note or phrases like "take a note", "capture this", "save this idea".
---

# quick-note

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`
Destination: `Resources/Inbox/<title>.md`

## Protocol

1. Confirm title (suggest from context if obvious, ask if missing)
2. Ask what it's about — one question, optional follow-up if needed. Don't push for more.
3. Search vault for related notes (Archive/, Area/, Inbox/) — max 2-3 matches
4. Create the file. Confirm with path + one-line summary.

## File format

```markdown
---
tags:
  - zettelkasten/fleeting
  - ai-assisted
  - status/pending
created: YYYY-MM-DD
modified: YYYY-MM-DD
sources: <URL if mentioned, else empty>
related: <[[note]] if found, else empty>
---
## ⚡ <title>

<content in user's words, lightly expanded if needed>
```

## Rules
- No date in filename — title only
- User's words first, don't rewrite in generic tone
- If user wants to finish fast, create with what's there
- Don't suggest converting to atomic note — that's /refine-notes
- If user references a file with `@name` or `[[name]]`, include it as `[[name]]`
