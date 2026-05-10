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
6. Confirm: "Linked: [[<name> Index]] ↔ `<repo path>`. /project-log will now find it automatically."

## Rules
- Verify repo has `.git` before creating the link
- Don't overwrite existing link without confirmation
- Create `<repo>/.claude/` if it doesn't exist
- `vault_path` is always relative from vault root
