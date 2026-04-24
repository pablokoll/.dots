---
name: project-link
description: Vincular un Project Index existente en el vault de Obsidian con un repo git existente. Invocá con /project-link o cuando el usuario diga "vinculá el proyecto", "linkear el repo con el vault", "conectar el proyecto al repo".
---

# project-link — Vincular Proyecto Vault ↔ Repo

Usá este skill cuando ya existe el Project Index en el vault Y ya existe el repo, pero todavía no están vinculados.

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocolo

### Paso 1: Identificar el Project Index

Si estás en el vault o el usuario mencionó el proyecto, sugerí el Index correspondiente y pedí confirmación.
Si no hay contexto claro, preguntá: "¿Cuál es el Project Index en el vault? (nombre del proyecto)"

Buscá con Grep en `Projects/` archivos con tag `project/index` para listar opciones si el usuario no sabe el nombre exacto.

### Paso 2: Identificar el repo

Si hay `.git` en el dir actual, sugerí ese path y pedí confirmación.
Si no, preguntá: "¿Cuál es el path del repo git?"
Verificá que el path exista y tenga `.git`.

### Paso 3: Verificar que no estén ya vinculados

- Si `<repo>/.claude/project-link.md` ya existe → avisá "Ya están vinculados" y mostrá el contenido. Preguntá si quiere sobreescribir.
- Si el Project Index ya tiene `repo:` en frontmatter → mismo aviso.

### Paso 4: Crear el vínculo

1. Crear `<repo>/.claude/project-link.md`:

```markdown
# Project Link
vault_path: <path relativo completo desde raíz del vault>/<nombre> Index.md
project_name: <nombre>
```

El `vault_path` es el path relativo real del archivo Index desde la raíz del vault. Puede ser `Projects/<nombre>/<nombre> Index.md` o `Projects/<subcarpeta>/<nombre>/<nombre> Index.md` según dónde viva el proyecto.

2. Actualizar el frontmatter del Project Index — agregar o actualizar campo `repo:`:

```yaml
repo: <path absoluto del repo>
```

3. Actualizar `modified:` en el frontmatter del Project Index.

### Paso 5: Confirmar

Mostrá:
- "Vinculado: [[<nombre> Index]] ↔ `<path repo>`"
- "Ahora `/project-log` desde ese repo encontrará automáticamente el Project Index."

## Reglas

- Verificar siempre que el repo tenga `.git` antes de crear el link
- No sobreescribir un link existente sin confirmación del usuario
- El campo `repo:` en el frontmatter es el path absoluto del repo
- Crear `.claude/` en el repo si no existe
