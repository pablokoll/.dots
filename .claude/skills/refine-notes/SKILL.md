# refine-notes — Note Refinement & Atomic Extraction

Usá este skill cuando el usuario invoque `/refine-notes` o diga algo como "refinemos esta nota", "trabajemos esta nota", "saquemos atomic notes de X", "pulidemos las notas de X".

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Tipos de notas

**Atomic note** — Un único concepto puntual. Corta y breve. Una atomic = un concepto.

**Molecule note** — Agrupa varias atomic notes como "hijas". Representa un proceso, conjunto temático, o idea mayor que solo tiene sentido cuando se conectan varios conceptos. La síntesis vive en la molecule, el detalle en las atomic notes.

## Protocolo

### Paso 1 — Identificar la nota a trabajar

Si el usuario invocó el skill con un path o nombre de nota, usalo directamente y saltá al Paso 2.

Si no hay path, leé `Area/Core.md` y buscá la sección `## 📖 Current Study Session`.
- Si existe y tiene items pendientes → preguntá: "¿Continuamos con [nota/item del Current Study Session] o querés trabajar una nota nueva?"
- Si no existe o está vacía → preguntá: "¿Qué nota querés trabajar hoy?"

Leé la nota elegida con Read tool.

### Paso 2 — Análisis silencioso (no mostrar aún)

Antes de responder, analizá internamente:

1. **Candidatos a atomic notes** — conceptos puntuales individuales
2. **Candidatos a molecule notes** — grupos de atomic notes que juntas forman un proceso o conjunto con identidad propia
3. **Errores o imprecisiones** — algo mal anotado, definición incorrecta, confusión entre conceptos
4. **Notas relacionadas existentes** — buscá en `Archive/` y `Projects/` con Grep/Glob
5. **Preguntas que el usuario dejó anotadas** — si la nota fuente tiene preguntas sin responder, tenerlas presentes

### Paso 3 — Presentar el panorama

Mostrá al usuario:

```
📋 Nota: <nombre>
Temas que cubre: <lista breve>

🔬 Candidatos a atomic notes:
- <concepto 1>
- <concepto 2>
- ...

🔗 Candidatos a molecule notes:
- <nombre del conjunto> → agrupa: <concepto A>, <concepto B>, <concepto C>

⚠️ Posibles errores o imprecisiones:
- <si hay algo, mencionarlo brevemente>

🔍 Notas relacionadas ya en el vault:
- [[<nota>]] — <por qué está relacionada>
```

Luego preguntá: "¿Por dónde arrancamos?"

### Paso 4 — Trabajar cada nota de forma conversacional

Por cada atomic/molecule note, seguí este flujo **de a una**:

#### 4a. Feynman primero
Preguntá al usuario: "¿Cómo explicarías <concepto> con tus palabras?"

Esperá su respuesta.

#### 4b. Evaluar la explicación
- Si hay errores o imprecisiones → señalálos y preguntá si quiere corregirlos antes de continuar
- Si se puede mejorar → sugerí la mejora y pedí confirmación
- Si está bien → confirmalo y avanzá

#### 4c. Preguntas del tema
Preguntá: "¿Tenés alguna pregunta sobre esto que quieras dejar registrada? ¿Algo que no te quedó del todo claro?"

Si el usuario tiene preguntas, también buscá si hay respuesta en el contenido original o en notas relacionadas, y proponé responderlas en el apartado Questions de la nota.

#### 4d. Proponer borrador
Basándote en:
- Las palabras del usuario (prioridad máxima)
- El contenido original de la nota (complemento)
- Las notas relacionadas encontradas (para linkear)
- Las preguntas y respuestas del usuario

Proponé el borrador completo. Breve. Sin relleno. Estructura de outline. Esperá aprobación o ajustes.

#### 4e. Definir destino
Si el usuario no lo dijo antes, preguntá dónde guardarla. Sugerí según el tema:
- Material de CS activo → `Projects/Computer Science/<carpeta>/`
- Material técnico procesado → `Archive/Engineering/`
- Otro tema → la carpeta correspondiente según CLAUDE.md

#### 4f. Crear el archivo

#### 4g. Continuar o terminar
Preguntá: "¿Seguimos con el próximo candidato o querés parar acá?"

### Paso 5 — Pulir nota original (opcional)

Al final del flujo, ofrecé: "¿Querés que pula la nota original también? (typos, redacción, frontmatter)"

Si acepta, mostrá los cambios propuestos y pedí confirmación antes de editar.

---

## Formato de notas a crear

### Atomic Note
Corta. Un concepto. Estructura de outline. Keywords para active recall.

```markdown
---
tags:
  - zettelkasten/permanent/atomic
  - <domain-tag>
  - status/pending
created: <YYYY-MM-DD>
modified: <YYYY-MM-DD>
sources:
  - <URL o [[nota origen]] si aplica, sino []>
related:
  - <[[notas relacionadas encontradas]]>
aliases: []
keywords:
  - <palabra clave 1 que dispare el recuerdo del concepto>
  - <palabra clave 2>
  - <agregar las que sean necesarias>
---

## 🧠 <Título del concepto>

> [!info] Main idea
> <Escrita AL FINAL. Una oración — la esencia del concepto en palabras del usuario.>

> [!question] Questions
> <Preguntas que surgieron mientras se tomaba la nota, con sus respuestas si las hay.>
> Q: <pregunta>
> A: <respuesta, o "pending" si no se resolvió>

## 📌 Data
<Contenido en palabras del usuario. Outline jerárquico — usá numeración o bullets con indentación para reflejar la estructura del concepto. Breve y puntual.>
1. <punto principal>
   - <subpunto si aplica>
   - <subpunto>
2. <otro punto principal>

---
##### 🧪 Practice
**Question:**
<Pregunta de active recall — basada en keywords o en la main idea>
?
**Answer:**
<Respuesta>
```

### Molecule Note
Síntesis del conjunto. El detalle vive en las atomic notes hijas. Outline para organizar los temas.

```markdown
---
tags:
  - zettelkasten/permanent/molecule
  - <domain-tag>
  - status/pending
created: <YYYY-MM-DD>
modified: <YYYY-MM-DD>
related:
  - <[[solo otras molecule notes aquí]]>
aliases:
---

> [!abstract] Key Points
> - <punto clave 1>
> - <punto clave 2>

---
## 🧠 <Título de la molecule>

> [!info] Core
> <Una o dos oraciones — qué es este conjunto y por qué tiene sentido agruparlo. Estilo Feynman.>

> [!question] Questions
> Q: <pregunta sobre el conjunto>
> A: <respuesta, o "pending">

### 📌 <Tema 1>
→ [[<atomic note>]]
<Una línea de contexto: qué aporta al conjunto>

### 📌 <Tema 2>
→ [[<atomic note>]]
<Una línea de contexto>

---
## 🧪 Practice
**Pregunta:**
?
**Respuesta:**
```

---

## Reglas

- **Dirigida por el usuario** — él decide qué nota, qué conceptos extraer, en qué orden. No avances sin su dirección.
- **Una nota a la vez** — nunca generes múltiples notas de golpe. Flujo conversacional por cada una.
- **Sus palabras primero** — el contenido final debe sonar a él. El original es complemento, no base.
- **Feynman antes del borrador** — siempre preguntá cómo explicaría el concepto antes de proponer algo.
- **Atomic = breve** — si la nota se extiende demasiado, hay múltiples conceptos. Separarlos.
- **Molecule = síntesis de atomic notes** — no tiene contenido extenso propio. Conecta y referencia.
- **Keywords = active recall** — elegí palabras que disparen el recuerdo del concepto, no solo descriptores genéricos.
- **Outline siempre** — toda nota usa estructura jerárquica con numeración o bullets indentados.
- **Questions = preguntas reales** — anotá las preguntas que el usuario haga durante la sesión y respondelas si es posible. Si no, marcalas como "pending".
- **Corrección honesta** — si algo está mal anotado, señalalo. No lo ignores.
- **No forzar fleeting** — crear directo como atomic o molecule si el contenido lo justifica.
- **Idioma de la nota** — seguí el idioma en que el usuario responda (inglés → inglés, español → español).
- **Links inline vs related** — si una nota se menciona en el texto, el link va inline `[[Nota]]`. El campo `related` es para notas relacionadas que no se mencionan en el cuerpo. Siempre dejar `related` presente en el frontmatter, vacío `[]` si no aplica.
- **Buscar relacionadas siempre** — antes de crear cualquier nota, buscá en el vault para identificar qué notas linkear (inline o en related). Incluí aliases en la búsqueda (Grep en frontmatter `aliases:`).
- **Aliases en notas nuevas** — al proponer el borrador, sugerí aliases candidatos de forma interactiva: plural, singular, abreviaciones, variantes de capitalización, sinónimos comunes. El usuario confirma cuáles incluir antes de crear el archivo.
- **Sources** — solo el nombre de la nota: `[[Nombre]]`, sin path completo.
- **No inventar contenido** — si el usuario no explicó algo, preguntá.
- **Nombre de archivo siempre en inglés** — independientemente del idioma del contenido de la nota.
