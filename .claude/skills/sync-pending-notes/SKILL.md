---
name: sync-pending-notes
description: Sincroniza las tareas pendientes de las daily notes al archivo Core.md del vault de Obsidian. Invocá con /sync-pending-notes o cuando el usuario diga algo como "sincronicemos los pendings", "actualizá los pendientes", "sync de notas", "actualizá el core", "quiero ver mis pendientes" o frases similares que indiquen querer sincronizar o ver las tareas pendientes del journal.
---

# Sync Pending Notes

Usá este skill cuando el usuario invoque `/sync-pending-notes`.

## Vault Path

`/home/pablo/Dropbox/Aplicaciones/remotely-save/personal-vault/`

## Qué hace

Sync bidireccional entre las daily notes y `Area/Core.md`:

1. **Propagación hacia atrás (primero):** lee el bloque Pendings actual de Core.md, detecta tasks marcadas como `- [x]`, y las marca como completadas en la daily note de origen.
2. **Extracción:** lee daily notes de los últimos 30 días, extrae `- [ ]` con texto real.
3. **Actualización:** reemplaza el bloque Pendings en Core.md con las tareas aún pendientes.

## Protocolo

### Paso 1: Leer el bloque Pendings actual de Core.md

Leé `Area/Core.md` y extraé el bloque entre `## 🎯 Pendings` y el siguiente `##`.

Buscá líneas con formato:
```
### YYYY-MM-DD
- [x] texto de tarea
```

Para cada tarea marcada como `- [x]`, guardá: `{ fecha: "YYYY-MM-DD", task: "texto exacto" }`.

### Paso 2: Propagar completadas a las daily notes

Para cada tarea completada encontrada en el paso anterior:
- Abrí el archivo `Area/Journal/<fecha>.md`
- Buscá la línea exacta `- [ ] <texto de tarea>` en ese archivo
- Si la encontrás, reemplazála por `- [x] <texto de tarea>`
- Si no la encontrás, ignorá sin error

### Paso 3: Leer las daily notes (últimos 30 días)

Usá Glob para encontrar todos los archivos en `Area/Journal/` que matcheen `????-??-??.md`.
Filtrá por fecha: solo los últimos 30 días desde hoy.
Ordenálos por nombre descendente (más reciente primero).

### Paso 4: Extraer pendientes

Para cada archivo, leélo y buscá líneas que:
- Empiecen con `- [ ]`
- Tengan al menos un carácter no-espacio después del `- [ ]`

**Excluir siempre** (sin importar si tienen texto adicional o no):
- Cualquier línea que contenga `Habitica Tracker`
- Cualquier línea que contenga `Exercise`

Guardá: `{ fecha: "YYYY-MM-DD", tasks: ["tarea 1", "tarea 2"] }`
Omití fechas sin pendientes válidos.

### Paso 5: Construir el bloque markdown

Formato del bloque a insertar:

```markdown
## 🎯 Pendings

> Actualizado: <YYYY-MM-DD HH:MM>

### <YYYY-MM-DD>
- [ ] <tarea>
- [ ] <tarea>

### <YYYY-MM-DD>
- [ ] <tarea>

```

### Paso 6: Actualizar Core.md

Leé `Area/Core.md`.
Reemplazá todo el contenido entre la línea `## 🎯 Pendings` (inclusive) y la siguiente línea que empiece con `##` (exclusive) con el bloque construido en el paso anterior.

### Paso 7: Confirmar

Mostrá un resumen:
- Cuántas tareas se propagaron como completadas a daily notes (si hubo alguna)
- Cuántas fechas y tareas pendientes quedan en Core.md

Ejemplo: "3 tareas marcadas como completadas en sus daily notes. Pendings actualizados: 4 fechas, 9 tareas."

## Reglas

- **Primero propagar, después actualizar** — el orden importa para no perder las marcas de completado
- Solo incluí tareas con texto real después del `- [ ]` (no vacías, no solo espacios)
- Excluir siempre: `Habitica Tracker` y `Exercise` (cualquier variante)
- No toques ninguna otra sección de Core.md ni de las daily notes
- Si no hay pendientes en los últimos 30 días, escribí `> Sin pendientes recientes.` en el bloque
- Las tareas deben aparecer tal cual están escritas en la daily note, sin modificar
