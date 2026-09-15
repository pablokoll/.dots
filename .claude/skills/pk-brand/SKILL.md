---
name: pk-brand
description: Load Pablo Koll's real design system tokens (colors, type scale, shadows, motion, JetBrains Mono font) before building any Artifact, slide, deck, chart, dashboard, or visual one-off that should look like pablokoll.com. Trigger whenever the user asks for something styled with "my design system", "mis colores", "mi identidad", "como mi portfolio", "en mi estilo", or names Pablo Koll's brand/site — even without saying those exact words, if they're clearly asking for a personal/branded visual (a slide, a diagram, a one-pager, a mockup) rather than a generic one. Do not use this for edits to the actual portfolio site itself (that repo has its own CLAUDE.md) — this skill is for *new, standalone* visual artifacts that should borrow the same identity.
---

# pk-brand

Pablo's real design tokens live in a source file, not in this skill — read them fresh every time, because the file can change and a stale copy would silently drift from the real site.

## 1. Read the tokens

```
/home/pablo/Work/personal/profile/brand/ds-portfolio/src/styles.css
```

This is the design-system mirror synced to claude.ai/design (see that project's own `.design-sync/conventions.md` for the component-level version of this same guidance). If that path is missing, fall back to `/home/pablo/Work/personal/profile/portfolio/src/styles/global.css` (the live site's source) and mention the fallback to the user.

Read the file directly — don't guess or reuse values from memory of a past artifact. Extract the actual hex values, not placeholders:

- **Light theme** (`:root`): surfaces (`--pk-white`, `--pk-gray-50`, `--pk-gray-100`, `--pk-border`), text (`--pk-fg-1/2/3`), accents (`--pk-steel`, `--pk-crimson`, `--pk-green`), extended pastels (`--pk-mauve`, `--pk-peach`, `--pk-yellow`, `--pk-pink`, `--pk-mint`, `--pk-sky`)
- **Dark theme** (`[data-theme="mocha"]`): the same token names, redefined — this is a Catppuccin Mocha-derived palette
- **Type scale**: `--fs-xs` through `--fs-4xl` (or `--fs-3xl` if 4xl isn't defined), plus matching `--lh-*` line-heights
- **Shadows**: `--shadow-xs/sm/md/lg`, `--shadow-focus`
- **Motion**: `--ease`, `--duration-1/2/3`
- **Font stack**: `--font-mono` — the family list starts with `"JetBrains Mono"`

Carry the *real* hex values into the artifact's CSS. Don't invent a palette that's merely "inspired by" what you read — copy the actual `--pk-*` values so the artifact is provably the same system, not a lookalike.

## 2. Embed the font

The Artifact CSP blocks Google Fonts and other CDN font links — a `@font-face` pointing at a URL will silently fall back to a system font. This skill bundles the actual JetBrains Mono woff2 files so you never need to re-download them:

```bash
bash ~/.claude/skills/pk-brand/scripts/font_data_uri.sh regular   # prints a data: URI
bash ~/.claude/skills/pk-brand/scripts/font_data_uri.sh bold
```

Splice the printed `data:font/woff2;base64,...` string into `@font-face { src: url('...') format('woff2'); }` for weights 400 and 700. If the artifact needs other weights the bundled files don't cover, note that to the user rather than silently substituting a different typeface.

## 3. Match the artifact-design skill's theme pattern

This skill's job is *which tokens*; the `artifact-design` skill (load it too, if not already active) covers *how to structure* an Artifact's dark/light support. Follow its pattern with Pablo's real values:

- Define every `--pk-*` / `--fs-*` / `--shadow-*` token on `:root` (the light/default values)
- Redefine the dark subset under `@media (prefers-color-scheme: dark)` — this carries the OS preference
- Redefine the same subset again under `:root[data-theme="dark"]` and `:root[data-theme="light"]` — these override the media query in both directions when the artifact viewer's own toggle is used
- Style components through the custom properties, never with hardcoded hex inside the media query or the dark override block

## 4. Design voice — don't default to generic

pablokoll.com is a **mono-first, terminal/CLI-flavored** identity, not a generic SaaS look. An artifact "in Pablo's style" should read as an extension of his site, which means:

- **Everything is monospace.** `--font-mono` is the only typeface in the system — no pairing it with a sans/serif display font. Hierarchy comes from size, weight, and color, not a second family.
- **Terminal vocabulary.** Labels and eyebrows in `snake_case` (`view_projects()`, `current_focus`), comments styled as `// like this`, prompts styled as `$ like this` (see `.comment`, `.subline`, `.prompt` in the source CSS for the exact convention — muted color, `::before` content).
- **Catppuccin-derived accents used sparingly.** `--pk-steel` is the primary accent (links, active states, primary actions); `--pk-crimson` is reserved for CTAs; the pastel set (mauve/peach/yellow/pink/mint/sky) is for per-item accents (tags, icons, chart series) — never as a whole-page gradient or hero treatment, which would clash with the site's restraint.
- **Cards, not gradients.** The site's signature surface is a bordered card with `border-radius: 10px`, `var(--shadow-md)` on hover with a `translateY(-2px)` lift — reuse `.card`/`.card-hover` semantics rather than inventing a new elevation language.
- **Numbers align.** Tables, stats, and any place digits stack vertically should use `font-variant-numeric: tabular-nums` — the source site does this throughout its data displays.

If the user's ask pulls toward something the tokens don't cover (e.g. a chart needs more than six categorical colors), extend thoughtfully from the existing hues rather than reaching for a generic categorical palette — derive lighter/darker steps from the same `--pk-*` values first.

## 5. Sanity check before publishing

Before calling the `Artifact` tool: grep the artifact's CSS for any hex value that doesn't trace back to something read from `styles.css` in step 1. A stray `#000000` or a color that "looked about right" is the failure mode this skill exists to prevent — every color should be attributable to a real token.
