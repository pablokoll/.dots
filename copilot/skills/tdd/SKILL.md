---
name: tdd
description: Test-Driven Development. Use when implementing any task — new feature, bug fix, or refactor. Trigger on /tdd or "implementemos con TDD", "escribamos los tests primero".
---

# tdd

## When to use
During the work phase — when executing a task from `Tasks.md`. One task = one TDD cycle.

## Core Principles

- **Tests verify behavior, not implementation** — test what the system does through its public interface, not how it does it internally. A good test survives a full refactor.
- **Vertical slices** — one test → one implementation → repeat. Never write all tests first, then all code.
- **No production code without a failing test first.** If you wrote code before the test, delete it. Start over.

## The Cycle

```
RED → GREEN → REFACTOR → repeat
```

### 1. RED — Write one failing test

- One behavior, one test
- Clear name: describes what the system does (`rejects empty email`, not `test1`)
- Test through public interface only — no internal methods, no implementation details
- Real code, not mocks (unless truly unavoidable)

Run it. Confirm it **fails** — and fails for the right reason (feature missing, not a typo).
If it passes immediately → you're testing existing behavior. Fix the test.

### 2. GREEN — Minimal code to pass

Write the simplest code that makes the test pass. Nothing more.
No extra features, no "while I'm here" improvements, no future-proofing.

Run it. Confirm it passes. Confirm other tests still pass.

### 3. REFACTOR — Clean up

Only after GREEN:
- Remove duplication
- Improve names
- Extract helpers
- Deepen modules (small interface, rich implementation)

Never refactor while RED. Keep tests green after every change.

### 4. Repeat

Next behavior → next test. One at a time.

## Planning (before first test)

Before writing any code:
- Confirm what the public interface should look like
- List the behaviors to test (not implementation steps) — get user approval
- Use the project's domain vocabulary (from `CONTEXT.md` if it exists)
- Respect existing ADRs in the area you're touching
- Design for testability — if it's hard to test, the interface is too coupled

**You can't test everything.** Focus on critical paths and complex logic.

## Tracer Bullet

First test = tracer bullet. Proves the path works end-to-end before building out.
Start with the most important behavior, not the easiest one.

## Red Flags — stop and restart

- Wrote code before the test
- Test passed immediately without implementation
- Can't explain why the test failed
- Test breaks on refactor but behavior didn't change (testing implementation, not behavior)
- Added mocks to avoid writing real code
- "I'll write tests after, just this once"

## Checklist per cycle

- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test would survive an internal refactor
- [ ] Watched it fail before implementing
- [ ] Wrote minimal code to pass
- [ ] All tests still pass after refactor

## When stuck

| Problem | Solution |
|---------|---------|
| Don't know how to test | Write the API you wish existed. Write the assertion first. |
| Test too complicated | Interface too complicated. Simplify it. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup is huge | Extract helpers. Still complex? Simplify the design. |

## Integration with workflow

- Runs during the **work phase** — one TDD cycle per task in `Tasks.md`
- Bug found mid-implementation? Write a failing test reproducing it → follow the cycle → feeds into `/diagnose` if needed
- Session done? `/project-log` captures what was built and tested
