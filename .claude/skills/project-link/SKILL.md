---
name: project-link
description: Link an existing Project Index in the vault to an existing git repo. Trigger on /project-link or "link the project", "connect repo to vault".
---

# project-link

## Vault
`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocol

1. Identify the Project Index — suggest from context or search `Projects/` for files with tag `project/index`
2. Identify the repo — use current dir if it has `.git`, otherwise ask for path
3. Check if already linked — if `<repo>/.claude/project-link.md` or `repo:` in frontmatter exist, warn and ask to overwrite
4. Create `<repo>/.claude/project-link.md`:

```markdown
# Project Link
vault_path: <relative path from vault root>/<name> Index.md
project_name: <name>
```

5. Add/update `repo: <absolute path>` in Project Index frontmatter + update `modified:`
6. Ask: "Want to link any subprojects? (e.g. a subfolder Index for `theme`, `api`, etc.)"
   - If yes: for each subproject, ask for its name (single lowercase word) and its Index path, then append to `project-link.md`:
     ```
     sub_vault_path_<name>: <relative path from vault root>/<subname> Index.md
     ```
   - Repeat until user says no more
7. Confirm: "Linked: [[<name> Index]] ↔ `<repo path>`" + list any subprojects added. "/project-log will now find it automatically."

## Subproject management
- To **add** a subproject later: re-run `/project-link`, choose "add subproject" — appends new entry without touching existing ones
- To **remove** a subproject: re-run `/project-link`, choose "remove subproject" — removes that entry, asks for confirmation
- Subproject `<name>` must be a single lowercase word (no hyphens, no spaces)

## project-link.md format (with subprojects)

```markdown
# Project Link
vault_path: Projects/<parent>/<name>/<name> Index.md
project_name: <name>
sub_vault_path_theme: Projects/<parent>/<name>/Kit Theme Horizon/Kit Theme Horizon Index.md
sub_vault_path_api: Projects/<parent>/<name>/Api/Api Index.md
```

## Rules
- Verify repo has `.git` before creating the link
- Don't overwrite existing link without confirmation
- Create `<repo>/.claude/` if it doesn't exist
- `vault_path` and all `sub_vault_path_*` values are always relative from vault root
- Each subproject name must be a single lowercase word
