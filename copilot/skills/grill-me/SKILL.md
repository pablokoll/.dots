---
name: grill-me
description: Ask clarifying questions before starting any task to align on intent and requirements
trigger: user says "grill me", invokes /grill-me, or asks to clarify a task before starting
---

# grill-me

Ask the minimum number of questions needed to fully understand the task — no more than 10.

## Protocol

1. Read the user's task description
2. Identify what's ambiguous or missing (scope, constraints, expected output, edge cases)
3. Ask questions **one at a time**, conversationally
4. Stop as soon as you have enough to proceed — don't hit 10 if 3 suffices
5. When done, summarize your understanding and ask for confirmation before starting

## Rules

- If `CONTEXT.md` exists in the vault project folder, read it before grilling
- One question per message
- No filler, no preamble — just the question
- If the task is already clear, say so and proceed
- Never use this for daily-note or journaling flows
