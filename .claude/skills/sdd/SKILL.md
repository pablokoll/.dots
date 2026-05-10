---
name: sdd
description: Subagent-Driven Development. Execute tasks from a Tasks.md file by dispatching isolated subagents. Trigger on /sdd or "ejecutemos con subagentes", "arrancamos los tasks", "implementemos el plan".
---

# sdd

## When to use
After `/to-issues` — when you have a `Tasks.md` and want to execute tasks with isolated subagents instead of working together in the same session.

## Why subagents
Each subagent gets a fresh context with only what it needs. No session pollution, no accumulated noise. You stay as coordinator — clean context for the full picture.

## Setup

1. Read `Tasks.md` — extract all tasks with full text and context
2. Read `CONTEXT.md` if it exists in the project folder
3. For each task, ask: **Light or Full mode?**
   - **Light** — implementer subagent + your review. Fast, for simple/mechanical tasks.
   - **Full** — implementer + spec reviewer + quality reviewer. For critical or complex tasks.

You choose per task. Default to Light unless the task is complex, touches critical paths, or involves architecture decisions.

---

## Per Task — Light Mode

### 1. Dispatch implementer
Use the implementer prompt below. Provide full task text + context — never make the subagent read files itself.

### 2. Handle implementer status
- **DONE** → review the summary, approve or request fixes
- **DONE_WITH_CONCERNS** → read concerns before approving
- **NEEDS_CONTEXT** → provide missing info, re-dispatch
- **BLOCKED** → assess: more context? more capable model? split the task? escalate to you?

### 3. Your review
Read the summary. Does it match the task? Good quality? Approve or send back.

### 4. Log
Capture summary → feed into `/project-log`

---

## Per Task — Full Mode

### 1. Dispatch implementer (same as Light)

### 2. Dispatch spec reviewer
Only after implementer is DONE. Provide: full task text + implementer's report.
Spec reviewer reads actual code — not just the report. Returns ✅ or ❌ with file:line references.
If ❌ → implementer fixes → spec reviewer reviews again.

### 3. Dispatch quality reviewer
Only after spec review passes (✅). Provide: implementer's report + base/head SHA.
Returns: Strengths, Issues (Critical/Important/Minor), Assessment.
If issues → implementer fixes → quality reviewer reviews again.

### 4. Log
Capture summary → feed into `/project-log`

---

## Implementer Prompt

```
You are implementing: [task name]

## Task
[FULL TEXT of task — paste it, don't make subagent read the file]

## Context
[Where this fits in the project. Dependencies. Architectural context. Paste relevant CONTEXT.md sections.]

## Before you begin
If anything is unclear — requirements, approach, dependencies — ask now before starting.

## Your job
1. Implement exactly what the task specifies
2. Follow TDD: write failing test → minimal code → refactor
3. Verify it works
4. Commit
5. Self-review (see below)
6. Report back

## Self-review before reporting
- Did I implement everything in the spec?
- Did I avoid overbuilding (YAGNI)?
- Do tests verify behavior, not mock behavior?
- Did I follow existing patterns in the codebase?

Fix any issues before reporting.

## Report format
- **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
- What was implemented
- Files changed
- Tests written and results
- Self-review findings (if any)
- Concerns or blockers (if any)
```

---

## Spec Reviewer Prompt

```
You are reviewing spec compliance for: [task name]

## What was requested
[FULL TEXT of task]

## What the implementer claims they built
[Implementer's report]

## Your job
Read the actual code — do not trust the report.

Check for:
- Missing requirements (skipped or misunderstood)
- Extra/unneeded work (over-engineered, added unrequested features)
- Misinterpretations (right feature, wrong way)

Report:
- ✅ Spec compliant
- ❌ Issues: [list specifically, with file:line references]
```

---

## Quality Reviewer Prompt

```
You are reviewing code quality for: [task name]

## What was implemented
[Implementer's report]

## Task requirements
[FULL TEXT of task]

## Commits reviewed
Base SHA: [sha before task]
Head SHA: [current sha]

## Your job
Review the implementation for quality. Focus on what this change contributed — not pre-existing issues.

Check:
- Each file has one clear responsibility
- Units are decomposed and independently testable
- Names are clear and accurate
- No unnecessary complexity
- Tests verify behavior, not implementation

Report: Strengths | Issues (Critical / Important / Minor) | Assessment (Approved / Needs fixes)
```

---

## Project Log Integration

After each task (Light or Full), collect from the subagent's report:
- Summary of what was done
- Files changed
- Key decisions made

Pass this directly to `/project-log` — no need to reconstruct from memory.

## Rules
- Never make a subagent read the Tasks.md or plan file — paste the full task text in the prompt
- Always include CONTEXT.md relevant sections in the implementer prompt
- Never dispatch quality reviewer before spec review passes
- If blocked: diagnose the blocker before re-dispatching — don't retry blindly
- Light mode by default — only go Full when complexity or risk warrants it
