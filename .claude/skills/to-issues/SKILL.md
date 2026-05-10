---
name: to-issues
description: Break a PRD or plan into small independent tasks. Trigger on /to-issues or "break this into tasks", "create the issues", "split into tasks".
---

# to-issues

## When to use
After `/to-prd` — takes a PRD or plan and splits it into small, independently workable tasks.

## Protocol

1. Read context — PRD from conversation, file, or ask: "What's the plan/PRD to break down?"
2. If in a repo, check `.claude/project-link.md` to find the Project Index
3. Explore codebase briefly if needed to understand scope and dependencies
4. Draft task list as vertical slices — each task should be independently completable
5. Ask: "Does the granularity look right? Anything to split further or merge?"
6. On confirmation, save to `<project-folder>/tasks/Tasks-<slug>.md` (create `tasks/` if needed) and add `- [ ]` items to `## ✅ TODO` in the Project Index

## Task types
- **HITL** (human-in-the-loop) — needs review or decision before continuing
- **AFK** (can complete without human) — fully autonomous

## Tasks file format

```markdown
---
tags:
  - project/tasks
created: YYYY-MM-DD
prd: [[PRD-<slug>]]
---

# Tasks: <Title>

## 🔴 Blocked / HITL
- [ ] <task> — needs: <what's blocking>

## 🟡 Up next
- [ ] <task>
  - Context: <brief note>
  - Depends on: <other task if any>

## 🟢 Ready
- [ ] <task>
- [ ] <task>

## ✅ Done
```

## Rules
- If `CONTEXT.md` exists in the vault project folder, read it before breaking down tasks
- Each task = one independently completable unit of work
- Vertical slices — thin end-to-end, not horizontal layers
- Flag dependencies explicitly
- HITL tasks go first — unblock them early
- Mirror `- [ ]` items to `## ✅ TODO` in the Project Index
- If no PRD exists, ask if user wants to run `/to-prd` first
