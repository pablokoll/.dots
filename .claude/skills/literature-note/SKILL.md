---
name: literature-note
description: Sesión de estudio activa para tomar literature notes en el vault de Obsidian mientras el usuario consume contenido. Invocá con /literature-note o cuando el usuario diga "tomemos una literature note de X" o "abrí una sesión de estudio para X".
---

# literature-note — Sesión de Estudio Activa

Usá este skill cuando el usuario invoque `/literature-note`, diga "tomemos una literature note de X", o "abrí una sesión de estudio para X".

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Tipos de source

| Tipo | Cómo Claude lo lee |
|------|-------------------|
| URL web / artículo / blog | `WebFetch` — Claude lo lee directamente |
| PDF | `Read` tool — soporte nativo (solo PDFs de texto; escaneados fallarán) |
| YouTube | Usuario pega el transcript manualmente (YouTube → "..." → "Show transcript") |

## Protocolo

### Paso 1 — Recibir el source

- Si el usuario invocó con un source → procesarlo según tipo
- Si no hay source → preguntar: "¿Cuál es el source? (URL, PDF path, o pegá el transcript)"
- Según tipo:
  - URL → `WebFetch`
  - PDF path → `Read`
  - Transcript pegado → recibirlo del chat directamente
- Si falla (PDF escaneado, URL inaccesible) → avisar al usuario y pedir que pegue el contenido manualmente

### Paso 2 — Confirmar título y autor

- Sugerir título basado en el source (título del artículo, video, o PDF)
- Extraer autor si está disponible en el source
- Preguntar confirmación o ajuste al usuario

### Paso 3 — Crear nota vacía

Crear `Resources/Inbox/<título en inglés>.md` con el siguiente contenido:

```markdown
---
tags:
  - zettelkasten/literature
  - status/pending
author: <extraído del source, o dejar vacío>
created: <YYYY-MM-DD>
sources:
  - <URL completa o [[Nombre]] si es una nota del vault>
keywords:
  -
---

## 📘 <Título>

> [!NOTE] Main idea
> ESCRIBIR AL FINAL DE TODO

## ❓ Questions / Open Doubts

## 📌 Main Ideas

---
## ⚛️ Posibles notas atómicas
```

Confirmar al usuario: `"Nota creada en Resources/Inbox/<título>.md — arrancamos cuando quieras."`

### Paso 4 — Sesión activa (loop principal)

Por cada mensaje del usuario durante la sesión:

1. **Verificar** la idea/anotación contra el source leído
2. **Si correcto** → incorporar a la nota con Edit tool:
   - Ideas van bajo `## 📌 Main Ideas` como `### 💡 Idea N`
   - Preguntas van bajo `## ❓ Questions / Open Doubts`
   - Escribir en palabras del usuario, no parafrasear en tono genérico
3. **Si incorrecto o impreciso** → señalar el error con la corrección exacta del source. Preguntar si quiere corregirlo antes de incorporar
4. **Sugerir atomic note candidate** si la idea lo amerita:
   - Buscar en vault con Grep (incluyendo campo `aliases:` en frontmatter)
   - Si ya existe → linkear `[[Nota]]` inline en el contenido de la idea + agregar `- [x] [[Nota]]` en sección ⚛️
   - Si no existe → agregar `- [ ] [[Nombre Sugerido]]` en sección ⚛️
5. **Confirmar brevemente** qué se hizo: `"Agregado bajo Idea 2."` o `"Pregunta anotada."`

**Durante la sesión: respuestas ultra-breves.** El foco está en la nota, no en el chat.

### Paso 5 — Cierre

Cuando el usuario diga "cerramos", "listo", "terminamos" o similar:

1. Proponer `keywords` basados en el contenido anotado (palabras que disparen active recall, no descriptores genéricos)
2. Proponer la **Main idea** (una oración estilo Feynman — como explicarle el tema a alguien que no sabe nada)
3. Esperar confirmación o ajuste del usuario
4. Actualizar `keywords`, `Main idea`, y `modified` en la nota
5. Mostrar path final de la nota
6. Listar los `- [ ]` pendientes de la sección ⚛️ si hay alguno
7. Recordar: `"Para procesar las atomic notes candidatas, usá /refine-notes sobre esta nota."`

---

## Formato de la sección ⚛️

```markdown
## ⚛️ Posibles notas atómicas
- [x] [[Nota Existente]]      ← ya existe en el vault, linkeada inline en el contenido
- [ ] [[Nueva Nota A Crear]]  ← candidata nueva, para procesar con /refine-notes
- [ ] [[Otra Nota Nueva]]
```

---

## Reglas

- **Nombre de archivo siempre en inglés** — independientemente del idioma del contenido
- **Palabras del usuario primero** — no reescribir en tono genérico
- **Verificar siempre contra el source** — si algo está mal, señalarlo honestamente antes de incorporar
- **Respuestas durante sesión: ultra-breves** — máx 1-2 líneas de confirmación
- **Buscar aliases** — al buscar notas relacionadas, hacer Grep incluyendo el campo `aliases:` en frontmatter
- **Main idea al final** — nunca escribirla al inicio; se construye al cerrar la sesión
- **No mover la nota** — queda en `Resources/Inbox/` hasta que el usuario decida moverla
- **No extraer atomic notes** — esa es responsabilidad de `/refine-notes`
- **Idioma del contenido** — coincidir con el idioma en que el usuario responde en la sesión
