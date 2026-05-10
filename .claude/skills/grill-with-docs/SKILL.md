---
name: grill-with-docs
description: Deep requirements session tied to a project, producing an ADR saved in the project's adr/ folder and linked to the Project Index
trigger: user says "grill me with docs", invokes /grill-with-docs, or wants to document a decision formally
---

# grill-with-docs

Like grill-me but deeper — up to 30 questions, one at a time. Output is a formal ADR saved to the project.

## Protocol

1. Identify the active project (check `.claude/project-link.md` if in a repo, or ask)
2. Ask clarifying questions one at a time — minimum needed, max 30
3. Cover: context, constraints, alternatives considered, decision, consequences
4. When grilling is complete, draft the ADR and show it for confirmation
5. Save to `<project-folder>/adrs/ADR-<NNN>-<slug>.md`
6. Add a link to the ADR under `## 🔑 Decisiones Importantes` in the Project Index

## ADR Format

```markdown
---
tags:
  - adr
date: <YYYY-MM-DD>
status: accepted
---

# ADR-<NNN>: <Title>

## Context
<What situation prompted this decision>

## Decision
<What was decided>

## Alternatives Considered
<Other options evaluated>

## Consequences
<Trade-offs, risks, follow-ups>
```

## Rules

- If `CONTEXT.md` exists in the vault project folder, read it before grilling
- One question per message
- NNN is zero-padded (001, 002...)
- Create `adrs/` folder if it doesn't exist
- Never skip the confirmation step before saving
