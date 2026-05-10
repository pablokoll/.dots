---
name: to-prd
description: Transform a grilling session or idea into a structured PRD saved in the project folder. Trigger on /to-prd or "write the PRD", "document this feature", "create the spec".
---

# to-prd

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## When to use
After `/grill-me` or `/grill-with-docs` — when you have enough context to document a feature, decision, or plan.

## Protocol

1. Read context from conversation (grilling output, user description)
2. If in a repo, check `.claude/project-link.md` to find the Project Index
3. Ask: "Is there anything missing before I write the PRD?"
4. Draft the PRD and show for confirmation
5. Save to `<project-folder>/plans/PRD-<slug>.md` (create `plans/` if needed)
6. Add link under `## 📁 Related Files` in the Project Index

## PRD format

```markdown
---
tags:
  - project/prd
created: YYYY-MM-DD
status: draft
---

# PRD: <Title>

## Problem
<What situation or pain prompted this>

## Solution
<What we're building and why this approach>

## User Stories
- As a <role>, I want <action>, so that <benefit>

## Technical Decisions
<Key implementation choices, modules, interfaces, schema/API changes>

## Out of Scope
<What we're explicitly not doing>

## Open Questions
<Unresolved decisions — feed these into /grill-with-docs if needed>
```

## Rules
- If `CONTEXT.md` exists in the vault project folder, read it before writing
- Never write the PRD without first confirming context is complete
- Keep it lean — no filler sections, skip what doesn't apply
- Open Questions feed back into `/grill-with-docs` for ADRs
- If no project linked, save to current dir as `plans/PRD-<slug>.md`
