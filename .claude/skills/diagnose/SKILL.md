---
name: diagnose
description: Systematic debugging methodology. Trigger on /diagnose or "debug this", "something's broken", "help me diagnose this".
---

# diagnose

## Core principle
Hypothesize before touching code. A fast, deterministic feedback loop beats random fixes.

## Protocol

### 0. Fast path
If the bug is obviously small (typo, wrong variable, clear one-liner) — fix it directly, no ceremony.

Use the full protocol when:
- Root cause isn't immediately obvious
- Bug reappears after a fix
- Multiple things could be causing it

### 1. Build a feedback loop
Before anything else — how do we reproduce this reliably?
- Identify the shortest path to see the bug
- Goal: a command or step you can run in <5 seconds to confirm it's broken/fixed
- Ask if needed: "How do you currently reproduce it?"

### 2. Reproduce
Confirm the bug is reproducible with the feedback loop. If not reproducible → stop and investigate why.

### 3. Hypothesize
Generate 3-5 ranked, falsifiable hypotheses:
```
Hypotheses (ranked by likelihood):
1. <most likely cause> — test by: <specific check>
2. <second candidate> — test by: <specific check>
3. ...
```
Ask: "Does this look right? Anything to add?"

### 4. Instrument
Test hypotheses one at a time, starting with the most likely:
- Add targeted logging or inspection
- Run the feedback loop
- Eliminate or confirm each hypothesis
- Don't fix yet — understand first

### 5. Fix + regression test
Once root cause confirmed:
- Apply minimal fix
- Write a regression test that would have caught this
- Run feedback loop to confirm fixed

### 6. Cleanup + post-mortem
- Remove debug instrumentation
- Brief post-mortem: "What caused it? What would have prevented it?"
- If significant: pass root cause + fix + post-mortem to `/project-log` to track in Work Log and session file

## Rules
- If `CONTEXT.md` exists in the vault project folder, read it before starting
- Never skip hypothesize — random fixes waste time
- Never refactor while debugging — one thing at a time
- If hypothesis 1-3 are all wrong, pause and re-hypothesize before continuing
- Feedback loop must be deterministic — flaky reproduction = flaky diagnosis
- Fast path for obvious bugs — don't over-engineer simple fixes
