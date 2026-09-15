---
name: switch-language
description: Switch the conversation language for the current session. Trigger on /switch-language, "vamos en español", "switch to english", "hablemos en español".
---

# switch-language

## Purpose
Toggle the active language for this session. Default is English (set in CLAUDE.md). Switch persists for the rest of the conversation until invoked again or session ends.

## Triggers

| Trigger | Action |
|---------|--------|
| `/switch-language español` | Switch to Spanish |
| `/switch-language english` | Switch to English |
| "vamos en español" | Switch to Spanish |
| "hablemos en inglés" / "back to english" | Switch to English |

## Protocol

1. Detect target language from args or phrase
2. Confirm the switch in the target language — one short line
3. Continue all responses in the new language from that point forward

## Rules
- Default language: **English** — applies when no switch has happened in the session
- Switch affects all responses: answers, vault notes, skill output, everything
- Vault note language follows active session language (overrides CLAUDE.md note language rule)
- If language is ambiguous, ask in current active language
- No need to remind the user of the switch after confirming — just do it
