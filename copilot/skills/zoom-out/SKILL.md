---
name: zoom-out
description: Strategic review of a project or system to detect architecture degradation, structural debt, and misaligned direction
trigger: user invokes /zoom-out manually
---

# zoom-out

Step back from the current work and assess the big picture. Works for any project — code repos or the Obsidian vault.

## Protocol

### For code projects
1. Read recent git log, current file structure, and any planning docs
2. Identify: growing complexity, violated patterns, missing abstractions, dead code, drift from original intent
3. Report findings as prioritized issues with a recommended action per issue
4. Ask: "Want to address any of these now or log them as TODOs?"

### For the Obsidian vault
1. Review folder structure, Core.md, active projects, and recent daily notes
2. Identify: structural drift, stale projects, broken workflows, areas that grew without clear ownership
3. Report findings prioritized by impact
4. This complements `/review-vault` (which handles operational issues like inbox and orphans) — zoom-out is strategic

## Output format

```
## Zoom-out: <project or vault>

### 🔴 Critical
- <issue> → <recommended action>

### 🟡 Worth addressing
- <issue> → <recommended action>

### 🟢 Observations
- <note>
```

## Rules

- Always user-invoked, never automatic
- Don't duplicate what `/review-vault` already covers operationally
- Offer to log findings as TODOs or ADRs when relevant
