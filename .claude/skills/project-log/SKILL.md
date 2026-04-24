---
name: project-log
description: Loggear trabajo realizado en un proyecto al Project Index del vault de Obsidian. Invocá con /project-log o cuando el usuario diga "anotemos el trabajo", "loggemos esto", "actualizá el project index", o cuando se esté por hacer /clear o /compact en una sesión con proyecto activo.
---

# project-log — Log de Trabajo en Proyecto

Usá este skill cuando el usuario invoque `/project-log`, o automáticamente antes de `/clear` o `/compact` si se detecta un Project Index vinculado.

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Protocolo

### Paso 0: Registrar tiempo de inicio

Al invocar el skill, registrá mentalmente el timestamp actual como `session_start`. Esto se usa al final para calcular la duración aproximada de la sesión.

Si la conversación lleva mucho tiempo (visible por la longitud del contexto o mensajes), estimá el tiempo de forma razonable — no tiene que ser exacto, solo aproximado (redondear a 5-10 min está bien).

### Paso 1: Encontrar el Project Index

Intentá en este orden:

1. Buscá `.claude/project-link.md` en el directorio actual → leé el campo `vault_path`
2. Si no hay link, buscá en el vault un `*Index.md` con tag `project/index` cuyo campo `repo:` coincida con el directorio actual
3. Si tampoco, preguntá al usuario: "¿Cuál es el Project Index de este proyecto en el vault?" o sugerí `/project-init` o `/project-link`

### Paso 2: Leer contexto git (silencioso)

Antes de preguntar nada, recolectá contexto del repo si hay `.git` en el dir actual:

```bash
git log --oneline -5          # últimos 5 commits
git diff --stat HEAD          # archivos modificados no commiteados
git status --short            # estado actual
```

Con esto armá un **borrador interno** de la entrada:
- Resumen inferido de los commits y cambios
- Lista de archivos tocados del diff/status
- Decisiones inferibles de los mensajes de commit

### Paso 3: Flujo conversacional guiado

Mostrá el borrador al usuario y preguntá de a una cosa:

1. **Resumen**: "Basándome en los commits y cambios, esto es lo que haría: `<resumen inferido>`. ¿Lo ajustamos o está bien?"
2. **Archivos**: "Detecté estos archivos tocados: `<lista>`. ¿Falta algo o querés cambiar algo?"
3. **Decisiones**: "¿Hubo alguna decisión importante que vale documentar? (o 'ninguna' para saltear)"
4. **Próximos pasos**: "¿Cuáles son los próximos pasos?"

Si no hay `.git` o el repo está limpio, arrancá con las preguntas de cero sin borrador.

Si el usuario da todo junto de golpe, procesalo directamente sin preguntar de nuevo.

### Paso 4: Calcular tiempo de sesión

Antes de escribir la entrada, estimá la duración de la sesión:

- Mirá el timestamp actual (`date`) vs el momento de inicio de la conversación
- Si no tenés el timestamp exacto, estimá razonablemente según la longitud del contexto y los temas tratados
- Redondeá a 5-10 min — no necesita ser exacto
- Si el usuario menciona explícitamente cuánto trabajó, usá eso

Determiná si la sesión tuvo **una sola tarea o múltiples**:
- **Una tarea**: el tiempo va en el título → `### YYYY-MM-DD (45 min)`
- **Múltiples tareas**: el tiempo va como campo separado → `**Tiempo:** 1h 20min`

### Paso 5: Actualizar Work Log

Agregá una nueva entrada al final de `## 📋 Work Log` en el Project Index.

**Formato una tarea:**
```markdown
### YYYY-MM-DD (45 min)
**Resumen:** <resumen confirmado>
**Archivos tocados:** <lista confirmada>
**Decisiones:** <decisiones, o "—">
**Próximos pasos:** <próximos pasos, o "—">
```

**Formato múltiples tareas:**
```markdown
### YYYY-MM-DD
**Tiempo:** 1h 20min
**Resumen:** <resumen confirmado>
**Archivos tocados:** <lista confirmada>
**Decisiones:** <decisiones, o "—">
**Próximos pasos:** <próximos pasos, o "—">
```

### Paso 6: Regenerar sección de Archivos del Proyecto

Escaneá la carpeta del proyecto en el vault con Glob y regenerá `## 📁 Archivos del Proyecto` listando todos los `.md` excepto el Index:

```markdown
## 📁 Archivos del Proyecto
<!-- auto-generado por /project-log — no editar manualmente -->
- [[archivo1]]
- [[archivo2]]
```

### Paso 7: Actualizar frontmatter

Actualizá el campo `modified:` del Project Index con la fecha actual (`YYYY-MM-DD`).

### Paso 8: Confirmar

Mostrá: "Logueado en [[<nombre> Index]]. Entrada del <fecha> agregada (~<tiempo> trabajado)."

## Trigger antes de /clear o /compact

1. Detectá si hay un Project Index vinculado (Paso 0)
2. Si existe, preguntá: "Antes de limpiar — ¿anotamos el trabajo de esta sesión en el Project Index?"
3. Si acepta → ejecutá el flujo completo
4. Si no → dejá pasar

## Reglas

- Siempre leer contexto git antes de preguntar — las preguntas son confirmación, no punto de partida
- Una pregunta a la vez
- El usuario dirige — si corrige el borrador, usá su versión
- `📁 Archivos del Proyecto` siempre se regenera automáticamente
- No modificar `🔑 Decisiones Importantes`, `🗣️ Meetings & Chats`, ni `✅ TODO` — son secciones manuales
- Si no hay git o el repo está limpio, preguntar de cero sin inventar
