---
name: daily-note
description: Crear la daily note del día en el vault de Obsidian. Invocá con /daily-note o cuando el usuario diga algo como "hagamos la daily note", "registremos el día", "anotemos cómo estuvo el día", "quiero escribir mi diario", "hacemos la nota del día?" o frases similares que indiquen querer registrar el día en el journal.
---

# Daily Note — Registro Diario

Usá este skill cuando el usuario invoque `/daily-note`.

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Destino de las notas

`Area/Journal/YYYY-MM-DD.md` (fecha del día actual)

## Protocolo

### Paso 1: Verificar si ya existe

Revisá si ya existe una nota para hoy en `Area/Journal/<fecha>.md`.
- Si existe: avisale al usuario y preguntá si quiere sobreescribirla o agregarle contenido.
- Si no existe: arrancá el flujo normalmente.

### Paso 2: Preguntar de a una (flujo conversacional)

Hacé UNA pregunta a la vez, en orden. Esperá la respuesta antes de la siguiente.

**Orden de preguntas:**

1. **Mood**: "¿Cómo estuvo el día? (Very Bad / Bad / Normal / Good / Excellent)"
2. **Energy**: "¿Cuánta energía tuviste? (1 = muy poca, 5 = máxima)"
3. **Notas del día**: "¿Qué pasó hoy? Contame lo que quieras — eventos, situaciones, pensamientos sueltos."
4. **Qué hiciste**: "¿Qué hiciste concretamente? (tareas, estudio, ejercicio — lo que aplique)"
5. **Cómo te sentís**: "¿Cómo te sentís ahora?"
6. **Para mañana**: "¿Algo que quieras recordar para mañana?"

**Tips:**
- Si el usuario responde con poco en alguna sección, está perfecto — no insistas.
- Si el usuario quiere saltear algo, respetalo.
- Podés hacer una pregunta de seguimiento si algo parece importante de capturar, pero no más de una.
- Si el usuario dice "dale" o "creala" antes de terminar todas las preguntas, creá la nota con lo que hay.

### Paso 3: Crear la nota

Creá el archivo en `Area/Journal/<YYYY-MM-DD>.md`.

**Formato del archivo:**

```markdown
---
id: <YYYY-MM-DD>
tags:
  - daily/note
created: <YYYY-MM-DDThh:mm+01:00>
modified: <YYYY-MM-DDThh:mm+01:00>
energy: <número del 1 al 5>
mood: <very bad|bad|normal|good|excellent>
---

## 📝 Notes
- <líneas con lo que el usuario contó del día — en sus propias palabras>

---
## ✅ What I did today
- Topic studied:
	- <tema si estudió algo, sino "">
	- Time spent: ~__ min
- Tasks:
	- <tareas que mencionó>
- <[ ] o [x] Exercise — si mencionó tipo de entrenamiento, incluilo como texto plano>
- [ ] Habitica Tracker

---
## 🫀 How I feel
- <lo que el usuario respondió sobre cómo se siente>

---
## 🔁 For tomorrow
- [ ] <tarea o recordatorio para mañana, si mencionó algo>
```

**Notas sobre el formato:**
- El contenido de `Notes` debe sonar a las palabras del usuario, no a texto generado.
- Si el usuario mencionó ejercicio, marcalo como `[x]` y añadí el tipo como texto plano si lo dijo (ej: `[x] Exercise - Gym Push Day`). Si no hizo ejercicio, dejalo como `[ ] Exercise`.
- `energy` y `mood` van en minúscula en el frontmatter.
- Si no hay tareas o no hay "para mañana", dejá el campo con guion vacío.
- No incluyas el campo `aliases`.

### Paso 4: Confirmar

Mostrá el path del archivo creado y un resumen de dos líneas: mood/energy y algo destacado del día.

## Reglas

- Una pregunta a la vez — no bombardees con todo el formulario junto
- Usá las palabras del usuario en el contenido, no reescribas en tono genérico
- Si el usuario ya sabe lo que quiere y pega todo de golpe, procesalo y creá la nota directo
- No agregues secciones extras que no estén en el template
- La nota va siempre en `Area/Journal/` con la fecha del día como nombre de archivo
