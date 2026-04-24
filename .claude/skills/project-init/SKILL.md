---
name: project-init
description: Inicializar un nuevo proyecto en el vault de Obsidian bajo Projects/. Invocá con /project-init o cuando el usuario diga "creemos un nuevo proyecto", "inicializá el proyecto", "nuevo proyecto en el vault", o cuando project-log no encuentre un Project Index para el proyecto actual.
---

# project-init — Inicializar Nuevo Proyecto

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Template

`Resources/Templates/Project Index.md`

## Protocolo

### Paso 1: Nombre del proyecto

Si hay nombre obvio del contexto (carpeta actual, repo, conversación), sugerilo y pedí confirmación.
Si no, preguntá: "¿Cómo se llama el proyecto?"

### Paso 2: Subcarpeta padre (opcional)

Preguntá: "¿Va bajo alguna subcarpeta en `Projects/`? (ej: `Barsa`, o 'no' para ponerlo directo en `Projects/`)"

- Si da subcarpeta → la carpeta del proyecto será `Projects/<subcarpeta>/<nombre>/` y el archivo `<nombre> Index.md`
- Si dice no → la carpeta será `Projects/<nombre>/` y el archivo `<nombre> Index.md`

El nombre del archivo Index es siempre el nombre del proyecto solo, nunca incluye la subcarpeta padre.

### Paso 3: Descripción

Preguntá: "Dame una descripción breve (una o dos oraciones). ¿De qué se trata?"

### Paso 4: Repo asociado

Detectá si hay `.git` en el directorio actual.

**Si hay `.git`:**
- Decile: "Detecté que estamos en un repo git (`<path actual>`). ¿Lo vinculamos al Project Index?"
- Si acepta → `repo: <path absoluto del repo>` en el frontmatter + crear `.claude/project-link.md` en el repo (ver formato abajo)
- Si no → omitir campo `repo:` del frontmatter completamente

**Si no hay `.git`:**
- Preguntá: "¿Hay un repo asociado a este proyecto? Si es así, ¿cuál es el path? (o 'no' para dejarlo sin repo)"
- Si da path → verificá que exista, poné `repo: <path>` en el frontmatter + crear `.claude/project-link.md` en ese repo
- Si dice no → omitir campo `repo:` del frontmatter completamente

### Paso 5: Verificar si ya existe

- Si la carpeta del proyecto ya existe y tiene `*Index.md` con tag `project/index` → avisá que ya existe, terminá
- Si la carpeta existe sin Index → avisá "La carpeta ya existe, creo el Index adentro"
- Si no existe → crear carpeta (y subcarpeta padre si aplica) y Index

### Paso 6: Crear archivos

Sea `<ruta>` = `Projects/<subcarpeta>/<nombre>/` o `Projects/<nombre>/` según Paso 2.

1. Crear carpeta `<ruta>` si no existe (incluyendo subcarpeta padre si aplica)
2. Crear `<ruta>/<nombre> Index.md` desde el template, reemplazando:
   - `{{title}}` → nombre del proyecto
   - `{{description}}` → descripción
   - `{{date}}` → fecha actual `YYYY-MM-DD`
   - `{{repo}}` → path del repo, o eliminar línea `repo:` si no hay

3. Si hay repo vinculado, crear `<repo>/.claude/project-link.md`:

```markdown
# Project Link
vault_path: <ruta>/<nombre> Index.md
project_name: <nombre>
```

### Paso 7: Confirmar

Mostrá:
- "Proyecto inicializado: [[<nombre> Index]] en `<ruta>`"
- Si hay repo: "Vinculado con `<path repo>`"

Preguntá: "¿Querés agregar tareas al TODO o notas iniciales ahora, o arrancamos a trabajar?"

## Reglas

- Nombre del archivo Index siempre: `<nombre del proyecto> Index.md` — nunca incluye la subcarpeta padre
- El campo `project:` en el frontmatter es el nombre del proyecto (sin subcarpeta)
- Si no hay repo, omitir el campo `repo:` del frontmatter (no dejarlo vacío)
- El `.claude/` en el repo se crea si no existe
- `vault_path` en el project-link siempre es el path relativo completo desde la raíz del vault
