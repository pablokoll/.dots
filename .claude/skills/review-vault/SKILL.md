---
name: review-vault
description: Auditoría periódica del vault de Obsidian. Escanea el vault, detecta issues priorizados, y guía al usuario conversacionalmente para resolverlos. Invocá con /review-vault o cuando el usuario diga "revisemos el vault", "hagamos una auditoría", "qué tengo pendiente en el vault".
---

# review-vault — Auditoría Periódica del Vault

Usá este skill cuando el usuario invoque `/review-vault` o diga "revisemos el vault", "hagamos una auditoría del vault", "qué tengo pendiente en el vault".

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Status Tags

El flujo de status de las notas es:
- `status/pending` — recién creada, sin trabajar
- `status/processing` — en proceso (siendo trabajada con /refine-notes o /literature-note)
- `status/finished` — completamente procesada

## Protocolo

### Paso 1 — Escaneo silencioso

Antes de mostrar nada, escanear el vault con Grep/Glob para detectar:

#### A. Inbox pendiente + status review
- Todas las notas en `Resources/Inbox/` → listar con fecha de creación
- Notas con `status/pending` en cualquier carpeta → cuántas hay y dónde
- Notas con `status/processing` → estas están "en vuelo", mencionar cuáles
- Notas con `status/finished` que **no** fueron movidas fuera de Inbox (posible olvido)

#### B. Literature notes con ⚛️ pendientes
- Buscar archivos con `- [ ]` dentro de la sección `## ⚛️ Posibles notas atómicas`
- Listar cuáles tienen candidatos sin procesar

#### C. Orphaned atomic/molecule notes
- Notas con tag `zettelkasten/permanent/atomic` o `zettelkasten/permanent/molecule`
- Que NO aparecen linkeadas en ninguna otra nota (Grep por `[[nombre de la nota]]`)
- Estas están "sueltas" — nadie las referencia

#### D. Frontmatter incompleto
- Notas permanentes (atomic/molecule) sin `keywords` o con `keywords:` vacío
- Notas sin campo `sources` o con `sources:` vacío cuando debería tenerlo
- Notas sin `related` (campo ausente del todo)

### Paso 2 — Presentar reporte priorizado

Mostrar al usuario:

```
🔍 Review del Vault — <fecha>

📥 Inbox & Status
- <N> notas en Resources/Inbox/ sin procesar
- <N> notas en status/pending fuera de Inbox
- <N> notas en status/processing (en vuelo)
⚠️ <nota> parece completa pero sigue en status/pending — ¿ya la terminaste?

⚛️ Literature notes con candidatos pendientes
- [[<nota>]] — <N> atomic notes sin procesar

🔗 Notas huérfanas (sin links entrantes)
- [[<nota>]] — <ubicación>

🛠️ Frontmatter incompleto
- [[<nota>]] — falta: keywords / sources / related
```

Luego preguntar: **"¿Por dónde arrancamos?"**

### Paso 3 — Loop conversacional (issue por issue)

El usuario elige una categoría o issue específico. Por cada issue:

#### Si es nota en Inbox sin procesar:
- Mostrar nombre, fecha de creación, y tag actual
- Preguntar: "¿Querés procesarla con /refine-notes, moverla directamente a Archive, o descartarla?"
- Si elige refine-notes → recordar: `"Usá /refine-notes sobre [[<nota>]] cuando estés listo"`
- Si elige mover → preguntar destino y mover el archivo
- Si elige descartar → confirmar antes de borrar

#### Si es literature note con ⚛️ pendientes:
- Mostrar la nota y listar los `- [ ]` pendientes
- Preguntar: "¿Arrancamos con /refine-notes sobre esta nota o lo dejás para después?"
- Recordar: `"Usá /refine-notes @'<path>' para procesarla"`

#### Si es nota huérfana:
- Mostrar la nota y su contenido brevemente
- Buscar en el vault notas que deberían linkearla (por tema/keywords)
- Sugerir: "Esta nota podría ser linkeada desde [[<nota relacionada>]] — ¿la agrego?"
- Si acepta → editar la nota relacionada para agregar el link inline o en `related`

#### Si es frontmatter incompleto:
- Mostrar qué falta específicamente
- Si faltan keywords → preguntar: "¿Cómo describirías esta nota en 2-3 palabras clave para recordarla?"
- Completar el frontmatter con lo que el usuario responda
- Actualizar `modified` al hacer cambios

#### Recordatorio de status:
- Si durante cualquier acción una nota queda completa → recordar: "Esta nota parece lista — ¿la marcamos como `status/finished`?"
- Si el usuario dice que sí → actualizar el tag en el frontmatter

### Paso 4 — Continuar o cerrar

Después de cada issue resuelto:
- "¿Seguimos con el próximo o cerramos acá?"
- Si hay issues críticos sin resolver (ej: notas en processing hace mucho tiempo) → mencionarlo antes de cerrar

---

## Delegación a otras skills

| Situación | Acción |
|-----------|--------|
| Nota en Inbox con contenido rico | Delegar a `/refine-notes` |
| Literature note con ⚛️ pendientes | Delegar a `/refine-notes` |
| Nota simple o fleeting vieja | Procesar inline o mover/borrar directamente |
| Frontmatter incompleto | Completar directamente en la sesión |
| Nota huérfana | Linkear directamente en la sesión |

---

## Reglas

- **Escaneo primero, hablar después** — nunca mostrar issues antes de haber escaneado todo
- **Reporte priorizado** — Inbox/status primero (más urgente), orphaned último (menos urgente)
- **Recordar status** — si una nota parece terminada y sigue en pending/processing, mencionarlo
- **No actuar sin confirmar** — antes de mover, borrar, o editar → pedir confirmación
- **Delegar complejidad** — para notas con contenido rico, sugerir /refine-notes en vez de procesar inline
- **Acción directa para lo simple** — frontmatter incompleto, links faltantes → resolver en la sesión
- **Usuario dirige** — él decide el orden, qué atacar, y qué dejar para después
