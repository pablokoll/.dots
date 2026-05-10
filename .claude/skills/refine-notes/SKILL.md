---
name: refine-notes
description: Interactive session to extract atomic and molecule notes from an existing note. Trigger on /refine-notes or "refine this note", "extract atomic notes from X", "work this note".
---

# refine-notes

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Note types
- **Atomic** — one concept, short, one atomic = one idea
- **Molecule** — groups multiple atomic notes; synthesis lives here, detail in the atomics

## Protocol

### 1. Identify note to work
- If path/name provided → read it directly
- If not → ask: "Which note do you want to work on?"

### 2. Silent analysis
Before responding, identify internally:
- Atomic note candidates (single concepts)
- Molecule note candidates (groups of atomics)
- Errors or imprecisions
- Related notes already in vault (search Archive/, Projects/)
- Unanswered questions in the source note

### 3. Present overview
```
📋 Note: <name>
Topics: <brief list>

🔬 Atomic candidates:
- <concept 1>
- <concept 2>

🔗 Molecule candidates:
- <name> → groups: <A>, <B>, <C>

⚠️ Possible errors:
- <if any>

🔍 Related notes in vault:
- [[<note>]] — <why related>
```
Ask: "Where do we start?"

### 4. Work each note conversationally (one at a time)

**a. Feynman first** — "How would you explain `<concept>` in your own words?"

**b. Questions** — "Any questions about this concept you want to keep on record?"
- These are questions the user had during study — they may or may not have the answer
- Try to answer from source content or vault notes
- If no answer found, mark as `pending`
- Questions + answers give context for understanding the concept

**c. Evaluate** — based on Feynman explanation and questions, flag errors or suggest improvements. Ask confirmation before continuing.

**d. Draft** — propose full note based on user's words (priority), source content (complement), related notes (for links). Wait for approval or adjustments.

**e. Destination** — suggest based on topic:
- Active CS study → `Projects/Computer Science/<folder>/`
- Processed technical → `Archive/Engineering/`
- Other → matching folder per vault structure

**f. Create file**

**g. Continue?** — "Next candidate or stop here?"

### 5. Polish source note (optional)
At the end offer: "Want me to clean up the source note too? (typos, frontmatter, structure)"
Show proposed changes, ask confirmation before editing.

---

## Atomic note format

```markdown
---
tags:
  - zettelkasten/permanent/atomic
  - <domain-tag>
  - status/pending
created: YYYY-MM-DD
modified: YYYY-MM-DD
sources:
  - <[[source note]] or URL>
related:
  - <[[related notes]]>
aliases: []
keywords:
  - <active recall trigger>
---

## 🧠 <Concept title>

> [!info] Main idea
> <Written LAST. One sentence — the essence in user's words.>

> [!question] Questions
> Q: <question>
> A: <answer or "pending">

## 📌 Data
1. <main point>
   - <subpoint>
2. <main point>

---
##### 🧪 Practice
**Question:** <active recall question>
?
**Answer:** <answer>
```

## Molecule note format

```markdown
---
tags:
  - zettelkasten/permanent/molecule
  - <domain-tag>
  - status/pending
created: YYYY-MM-DD
modified: YYYY-MM-DD
related:
  - <[[other molecule notes only]]>
aliases:
---

> [!abstract] Key Points
> - <key point 1>
> - <key point 2>

---
## 🧠 <Molecule title>

> [!info] Core
> <What this group is and why it makes sense together. Feynman style.>

> [!question] Questions
> Q: <question>
> A: <answer or "pending">

### 📌 <Topic 1>
→ [[<atomic note>]]
<One line: what it contributes to the group>

### 📌 <Topic 2>
→ [[<atomic note>]]

---
## 🧪 Practice
**Question:** ?
**Answer:**
```

## Rules
- User directs — they decide what to extract and in what order
- One note at a time — never generate multiple notes at once
- User's words first — source is complement, not base
- Feynman before draft — always ask how they'd explain it first
- Atomic = brief — if it's getting long, there are multiple concepts, split them
- Molecule = synthesis — no extensive content of its own, just connects atomics
- Keywords = active recall triggers, not generic descriptors
- Flag errors honestly — don't ignore imprecisions
- Filename always in English
- `related` field: links not mentioned in the body. Always present, empty `[]` if none
- Search vault for related notes before creating (include `aliases:` in search)
- Suggest aliases interactively before creating the file
