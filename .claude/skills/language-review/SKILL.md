---
name: language-review
description: Review the user's English grammar and writing errors from recent messages. Trigger on /language-review or "review my english", "check my grammar", "correct my messages".
---

# language-review

## Purpose
Review the user's own messages from this session for grammar, spelling, and natural English usage. Mark errors and show the correct form. Teaching tool — not just correction.

## Protocol

1. Look back at the user's messages in the current conversation
2. Collect sentences or phrases with errors (grammar, spelling, word choice, unnatural phrasing)
3. Present each correction in this format:

```
❌ <what the user wrote>
✅ <correct form>
💡 <one-line explanation of why>
```

4. If no errors found: say so briefly — "No errors found. Your English looks good."
5. End with a short overall note: one pattern to watch (e.g. "watch article usage", "avoid direct translation from Spanish") — only if a pattern is clear.

## Rules
- Only review the **user's messages** — never Claude's output
- Focus on errors that affect clarity or naturalness, not stylistic preferences
- Don't over-correct informal or intentional shorthand (caveman mode, quick commands)
- If the user writes in Spanish in this session, skip those messages — only review English ones
- Keep it concise — this is a review, not a lesson
- Always output in English regardless of session language
