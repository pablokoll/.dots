---
name: project-analysis
description: Create a structured analysis note in the vault from a research note, conversation, or loose findings. Produces a fixed-section analysis document saved under analyses/ in the project or vault. Trigger on /project-analysis, /project-analysis <topic>, "analicemos esto", "hacemos el análisis de", "quiero sacar conclusiones de", "escribamos el análisis", or after completing a /project-research session.
---

# project-analysis

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Purpose
Turn research, findings, or raw context into a structured analysis note with actionable conclusions. Works from a `/project-research` note, a conversation, loose notes, or a mix of sources.

## Setup

### 1. Determine topic
- If argument provided: use it as the topic.
- If no argument: ask "¿Qué analizamos? (o pasame la nota de research si tenés una)"

### 2. Find the input
Ask or detect — in priority order:
1. **Research note**: check if there's a `researches/` folder in the project vault path. If yes, list available research notes and let the user pick one (or use the most recent).
2. **Loose context**: user provides findings, links, notes, or a conversation summary inline.
3. **From scratch**: no prior research — Claude and user work from what's available in the session.

### 3. Find the vault destination
- Check `.claude/project-link.md` in current dir.
  - If found: read `vault_path`, derive project folder, save to `<vault_root>/<project_folder>/analyses/<YYYY-MM-DD> - <topic-slug>.md`
  - If not found: save to `<vault_root>/Resources/Analysis/<YYYY-MM-DD> - <topic-slug>.md`
- `topic-slug`: lowercase, hyphens, no spaces

### 4. Draft the analysis note
Before writing to disk, present a draft in conversation. Ask: "¿Ajustamos algo antes de guardar?"

---

## Analysis Note Structure

```markdown
---
topic: <topic>
date: <YYYY-MM-DD>
status: draft | final
tags:
  - analysis
research: [[researches/YYYY-MM-DD - <slug>]] <!-- if applicable -->
---

# Analysis: <topic>

## Context
<!-- What prompted this analysis. What question are we answering. -->

## Findings
<!-- Key facts and observations from research or session. No interpretation yet — just what's true. -->
- ...

## Analysis
<!-- Interpretation of the findings. Patterns, tensions, trade-offs, implications. -->

## Conclusions
<!-- Direct answers to the original question(s). Crisp, assertive. -->
- ...

## Recommendations
<!-- Actionable next steps. Concrete, prioritized. -->
- [ ] ...

## Open Questions
<!-- What remains uncertain or needs further investigation. -->
- ...
```

---

## Protocol

### If input is a research note
1. Read the research note fully.
2. Extract findings → populate `## Findings`.
3. Draft `## Context` from the research topic and summary.
4. Generate `## Analysis` — synthesize patterns, tensions, trade-offs.
5. Derive `## Conclusions` — direct answers to what the research was investigating.
6. Propose `## Recommendations` — concrete actions, prioritized.
7. Flag `## Open Questions` — gaps not resolved by the research.
8. Present draft, discuss, refine, then write to disk.

### If input is loose context or from scratch
1. Ask: "¿Cuál es la pregunta central que querés responder con este análisis?" — this becomes the anchor for `## Context`.
2. Ask the user to dump what tienen — notas, links, conclusiones propias, lo que sea.
3. Claude complements with web searches if needed.
4. Build the note sections iteratively — present each section, adjust, move forward.
5. Write to disk once the user confirms.

---

## Integration points

- **After `/project-research`**: link the research note in frontmatter (`research:` field). Read it fully as the primary input.
- **Findings suggest an architecture decision**: propose running `/grill-with-docs` to produce a formal ADR. Don't absorb ADR content into the analysis — keep them separate.
- **Findings reveal structural/strategic problems**: mention `/zoom-out` as a follow-up if appropriate.

---

## Completion

When the note is saved:
1. If inside a project with `project-link.md`: offer to log the analysis to the Project Index via `/project-log`.
2. Tell the user: "Análisis guardado en `<path>`. Podés continuarlo cambiando `status: draft` a `final` cuando estés conforme."

---

## Rules
- Always present a draft before writing to disk.
- `## Findings` = facts only, no interpretation.
- `## Analysis` = interpretation only, no new facts.
- `## Conclusions` = crisp, assertive — no "podría ser" or "tal vez".
- `## Recommendations` = always a checklist, always actionable.
- Note language matches user's response language.
- Filename: `YYYY-MM-DD - <topic-slug>.md`
