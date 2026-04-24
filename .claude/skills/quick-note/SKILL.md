---
name: quick-note
description: Captura rápida de fleeting notes en el vault de Obsidian con asistencia de IA. Invocá con /quick-note "título" o cuando el usuario diga algo como "tomemos una nota", "anotá esto", "quiero guardar una idea", "hacemos una quick note", "capturá esto en obsidian", "anotame X" o frases similares que indiquen querer guardar una idea o pensamiento rápido.
---

# Quick Note — Captura Rápida de Ideas

Usá este skill cuando el usuario invoque `/quick-note` con un título o idea.

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocolo

### Paso 1: Confirmar título

Mostrá el título que el usuario pasó y preguntá si lo quiere ajustar o si está bien así.
Si no pasó título, pedíselo.

### Paso 2: Entender la idea (máx 2-3 preguntas, conversacional)

Preguntá brevemente de qué se trata la idea. Hacé UNA pregunta a la vez:
- "¿De qué se trata? Dame un poco de contexto."
- Si mencionó un link → confirmá que lo incluyas en `sources:`
- Si la idea lo amerita, una pregunta más de profundidad opcional

**Importante:** No abrumes. Si el usuario dice poco, está bien. La nota puede quedar mínima.

### Paso 3: Buscar notas relacionadas

Buscá en TODO el vault notas que puedan estar relacionadas con la idea, principalmente en:
- `Archive/` (todo el contenido archivado)
- `Area/` (áreas de responsabilidad)
- `Resources/Inbox/` (notas pendientes)

Usá Grep/Glob para buscar por keywords del título y contenido capturado.
Identificá 2-3 notas relacionadas máximo. Si no encontrás nada relevante, dejá `related:` vacío.

### Paso 4: Crear la nota

Creá el archivo en `Resources/Inbox/<título>.md` (sin fecha en el nombre de archivo).

**Formato del archivo:**

```markdown
---
tags:
  - zettelkasten/fleeting
  - ai-assisted
created: <YYYY-MM-DD fecha actual>
modified: <YYYY-MM-DD fecha actual>
sources: <URL si el usuario mencionó alguna, sino dejar vacío>
related: <[[nota relacionada]] si encontraste, sino dejar vacío>
---
## ⚡ <título>

<contenido capturado en la conversación — escrito con las palabras del usuario, expandido levemente si hace falta>
```

### Paso 5: Confirmar

Mostrá el path del archivo creado y un resumen de una línea de qué quedó en la nota.

## Reglas

- **Sin fecha en el nombre del archivo** — solo el título limpio
- El tag `ai-assisted` siempre presente junto a `zettelkasten/fleeting`
- El contenido debe sonar a las palabras del usuario, no a texto generado genérico
- Si el usuario quiere terminar rápido sin dar más detalles, respetalo — creá la nota con lo que hay
- No propongas convertirla en atomic note ahora — eso es trabajo del weekly review
