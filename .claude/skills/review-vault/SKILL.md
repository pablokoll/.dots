---
name: review-vault
description: Operational audit of the Obsidian vault. Trigger on /review-vault or "review the vault", "what's pending in the vault", "vault audit".
---

# review-vault

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Status tags
- `status/pending` — just created, unprocessed
- `status/processing` — being worked on
- `status/finished` — fully processed

## Protocol

### 1. Silent scan
Scan vault before showing anything:

**A. Inbox & status**
- All notes in `Resources/Inbox/` → list with creation date
- Notes with `status/pending` outside Inbox
- Notes with `status/processing` — list which ones
- Notes with `status/finished` still in Inbox (possible oversight)

**B. Literature notes with pending atomic candidates**
- Files with `- [ ]` inside `## ⚛️ Posibles notas atómicas`

**C. Orphaned permanent notes**
- Tags `zettelkasten/permanent/atomic` or `molecule` not linked from any other note

**D. Incomplete frontmatter**
- Permanent notes missing `keywords`, `sources`, or `related`

### 2. Show prioritized report

```
🔍 Vault Review — <date>

📥 Inbox & Status
- <N> unprocessed notes in Inbox
- <N> notes in status/pending outside Inbox
- <N> notes in status/processing

⚛️ Literature notes with pending candidates
- [[<note>]] — <N> unprocessed

🔗 Orphaned notes
- [[<note>]] — <location>

🛠️ Incomplete frontmatter
- [[<note>]] — missing: keywords / sources / related
```

Then ask: **"Where do we start?"**

### 3. Work through issues one by one

**Inbox note** → ask: process with `/refine-notes`, move to Archive, or discard?

**Inbox note with status/finished** → ask to move to Archive. Suggest subfolder based on content:
- Engineering/technical → `Archive/Engineering/`
- Entertainment → `Archive/Entertainment/`
- Recipes → `Archive/Recipes/`
- Coffee → `Archive/Coffee's/`
- Dogs → `Archive/Dogs/`
- Exercises → `Archive/Exercises/`
- Travel → `Archive/Travels/`
- Finance → `Archive/Finance/`
- General/uncategorized → `Archive/General/`

**Literature note with ⚛️ pending** → remind: `"Use /refine-notes on [[<note>]]"`

**Orphan** → find related notes, suggest adding link, edit if confirmed

**Incomplete frontmatter** → fix inline, ask for missing values, update `modified:`

After each issue: "Continue to the next or stop here?"

## Delegation
- Rich Inbox notes or literature notes with candidates → delegate to `/refine-notes`
- Simple frontmatter, missing links → fix directly in session

## Rules
- Scan everything before showing anything
- Inbox/status first (most urgent), orphans last
- Never move, delete, or edit without confirmation
- If a note looks done but is still in pending/processing, flag it
