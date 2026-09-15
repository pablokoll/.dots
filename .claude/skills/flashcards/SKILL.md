---
name: flashcards
description: Generate Brainscape-ready flashcard CSVs from vault notes on a topic (e.g. a CS50 week). Trigger on /flashcards <topic/week> or phrases like "generá flashcards de X", "hacemos las flashcards de esta semana".
---

# flashcards

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocol

1. **Identify scope** — the topic/week the user names (e.g. "Week 5", a folder, a single note). Read the index note if it's a week, and every atomic note it links to.
2. **Location** — default to `Archive/Engineering/Flashcards/<Subject>/<Topic Name> Flashcard.csv`, where `<Subject>` matches the source notes' area (e.g. `CS50`, `Data Structures and Algorithms`). If source notes live in inconsistent places or the subject is ambiguous, ask.
   - For a subject that's actively growing (e.g. working through a book + NeetCode + scattered vault notes on the same broad area), split by sub-topic instead of one monolithic CSV — one file per concept cluster (e.g. `Sorting & Searching`, `Stack Exercises`, `Binary Search Exercises`). Each grows independently as more content on that sub-topic shows up, instead of requiring a full re-read of one giant file every time. Ask the user if it's unclear whether the subject is a one-off or ongoing.
   - Default: mix theory notes and hands-on exercise notes (LeetCode/NeetCode-style, with code and bugs) into the same CSV per topic (e.g. one "Two Pointers" CSV covering both the concept and its exercises) — one deck to study per topic. If it's unclear whether a topic's exercises should join its theory CSV or stay separate (e.g. the exercise set is huge, or spans multiple unrelated theory topics), ask.
3. **Name the topic** — ask the user for a short descriptive name for the set (e.g. "Representation & Algorithms") if not already established, in English unless the user is working in Spanish.
4. **Content criteria (fixed, don't ask):**
   - Read the full note — Main idea + Data + existing Practice — not just existing Practice Q&A.
   - Generate new questions covering useful content even if no Practice card already exists for it.
   - If a concept is linked from the index/topic but has no atomic note in the vault, still generate a card for it using general knowledge of the subject — don't skip it and don't stop to ask.
   - Duplication across sets is fine and expected — the user may want to mix decks later (e.g. combine several weeks in Brainscape), so the same concept can legitimately get a card in more than one CSV. Don't skip a concept just because another CSV already covers it.
   - No pure syntax-lookup trivia — skip cards that just ask "which symbol/keyword/specifier does X use" (format specifiers, which quote type, list of operators, loop syntax shape). That's reference material, not recall worth testing. Every card should require understanding a distinction, a why, a trade-off, or a mechanism — not memorizing a token.
5. **Ask per session, don't assume:**
   - Language for the cards (technical terms stay in their original language regardless).
   - Card cap per CSV (rough guide: 15-30 depending on topic density — don't force a fixed number, ask what feels right for how much content there is).
6. **Generate CSV** — 2 columns `question,answer`, no header, one row per card. Quote fields containing commas.
7. **Update source notes** — append `Flashcards: [[<Topic Name> Flashcard]]` to every atomic note that contributed content, unless already present.
8. **NotebookLM as a judgment call** — before generating cards for a topic, actively query NotebookLM (invoke the `/notebooklm` skill, never call `nlm` directly) with 1-2 specific questions aimed at surfacing non-obvious distinctions, comparisons, edge cases, and misconceptions beyond what the note already says — not just a fallback for thin notes. Use the answer to replace generic "¿Qué es X?" trivia with deeper questions. Watch scope: only pull in content that actually belongs to the topic/week being generated — don't import concepts from other weeks/topics just because NotebookLM mentions them in passing.

## Re-running on an already-covered topic

A note can belong to more than one flashcard set. When regenerating:
- Don't blindly overwrite every CSV that references a changed note.
- Check what changed in the note, then update only the CSV(s) where that change affects an existing question/answer or adds genuinely useful related content for that specific set's scope.
- Never duplicate the `Flashcards: [[...]]` reference in a note if it's already there.

## Output format example

```csv
"¿Qué es un Algorithm?","Es la secuencia paso a paso de instrucciones para resolver un problema."
"¿Qué es Pseudocode?","Una descripción en lenguaje natural de los pasos de un Algorithm."
```

## Rules
- No header row — Brainscape's importer doesn't need or want one.
- Don't build any automation for uploading to Brainscape — that step is always manual (Upload File → Analyze → Add cards). No public API to automate against.
- Don't create the Flashcards subfolder structure speculatively — only create `<Subject>/` when generating its first CSV.
