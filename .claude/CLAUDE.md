# Configuración Global de Claude Code

## Modo de Comunicación

- **Caveman mode SIEMPRE activo** — responde terse como caveman inteligente. Sin artículos, sin filler, sin cortesías. Fragmentos OK. Sinónimos cortos. Patrón: `[cosa] [acción] [razón]. [siguiente paso].` Código/commits/seguridad: escritura normal. Intensidad: full.

## Instrucciones Generales

- Todo lo que sea sudo me lo pasas y yo lo ejecuto en otra terminal que quiero que puedas revisar el resultado en caso de que yo te lo pida, sino solamente espera a que yo te dé la orden de continuar
- Si no estás dentro de un proyecto, todo lo que tengas que clonar de repositorios o descargar lo haces dentro de ~/Documents o ~/Downloads (si no sabes cuál de los dos, pregúntame)
- Al crear notas en el vault (daily note, quick note, etc.), si respondí en inglés revisá ortografía y gramática del inglés al final y preguntame si quiero corregir algo. No hagas esto en conversaciones normales ni en español.
- Al crear notas (daily note, quick note, o cualquier otro archivo en el vault), el idioma del contenido debe coincidir con el idioma en que escribí las respuestas. Si respondí en inglés → nota en inglés. Si respondí en español → nota en español.
- La configuración de Claude Code está en ~/.claude/
- Para todo lo relacionado con Hyprland, Omarchy, configuración del OS, nvim, dotfiles, LazyVim, y temas similares de mi entorno de escritorio/sistema, usa el agente de Omarchy (Task tool con contexto de documentación de Omarchy)

---

## 🔄 Workflow Estándar

### Paso 1: Iniciar Sesión
```bash
/workflow-init
```
**Qué hace:**
- Crea estructura `.claude/session/` en el proyecto actual
- Genera reportes base: session-info, research, planning, implementation-status, qa-report
- Registra fecha/hora de inicio y objetivos

### Paso 2: Research (Investigación)
```bash
/workflow-research
```
**Qué hace:**
- Investiga codebase, documentación, arquitectura existente
- Analiza el problema o tarea a resolver
- Documenta hallazgos en `.claude/session/research.md`
- Lista archivos/componentes relevantes encontrados
- Identifica dependencias y constraints

**Output:** Reporte de research con contexto completo

### Paso 3: Planificación
```bash
/workflow-plan [--format=simple|detailed]
```
**Qué hace:**
- Lee el reporte de research como base
- Genera plan de implementación
- Define arquitectura y tecnologías
- Documenta en `.claude/session/planning.md`
- Lista tareas ordenadas por prioridad

**Formatos:**
- `simple` (default): Plan ágil y conciso
- `detailed`: Plan completo con arquitectura

**Output:** Plan estructurado listo para implementar

### Paso 4: Implementación
**Trabajo normal de coding, refactoring, debugging**
- Claude trabaja en el código según el plan
- Actualiza estado periódicamente con `/workflow-status`
- Documenta decisiones importantes

### Paso 5: Actualizar Estado (Durante implementación)
```bash
/workflow-status
```
**Qué hace:**
- Actualiza `.claude/session/implementation-status.md`
- Muestra: ✅ Completado | 🚧 En progreso | ⏳ Pendiente | 🐛 Issues
- Documenta decisiones técnicas tomadas

### Paso 6: Quality Assurance
```bash
/workflow-qa [--scope=all|functionality|code|architecture]
```
**Qué hace:**
- Lee el plan y compara con implementación
- Sugiere pruebas necesarias (unit, integration, e2e)
- Ejecuta tests si se confirma
- Audita calidad del código
- Genera reporte en `.claude/session/qa-report.md`
- Proporciona score de calidad y recomendaciones

**Scopes:**
- `all`: Auditoría completa (default)
- `functionality`: Solo funcionalidad y tests
- `code`: Solo calidad de código
- `architecture`: Solo arquitectura

### Paso 7: Commit
```bash
/commit [tipo] [scope] ["mensaje"]
```
**Qué hace:**
- Analiza cambios con `git status` y `git diff`
- Auto-detecta tipo y scope si no se especifican
- Genera mensaje conventional commit
- Muestra mensaje y pide confirmación
- Ejecuta commit

### Paso 8: Notas en Obsidian (Opcional)
```bash
/obsidian-note "contenido de la nota"
/obsidian-sync
```
**Qué hace:**
- Crea notas de proyecto en Obsidian
- Sincroniza reportes de sesión a Obsidian vault

---

## 📋 Comandos Disponibles

### Workflow (Flujo de trabajo)
| Comando | Descripción |
|---------|-------------|
| `/workflow-init` | Iniciar sesión con estructura de reportes |
| `/workflow-research` | Fase de research e investigación |
| `/workflow-plan` | Planificación basada en research |
| `/workflow-status` | Actualizar estado de implementación |
| `/workflow-qa` | Quality assurance y testing |

### Tools (Herramientas utilitarias)
| Comando | Descripción |
|---------|-------------|
| `/commit` | Commit inteligente con conventional commits |
| `/docs` | Generar/actualizar documentación |
| `/perf` | Análisis de performance |
| `/security` | Análisis de seguridad |

### Obsidian (Integración con Obsidian)
| Comando | Descripción |
|---------|-------------|
| `/obsidian-note` | Crear nota rápida en vault |
| `/obsidian-project` | Crear nota de proyecto con contexto completo |
| `/obsidian-sync` | Sincronizar reportes de sesión a Obsidian |
| `/obsidian-search` | Buscar notas en vault |

---

## 📁 Estructura de Sesión

Cada proyecto tendrá una carpeta `.claude/session/` con:

```
.claude/session/
├── session-info.md           # Info general (fecha, objetivos, proyecto)
├── research.md               # 📋 Hallazgos del research
├── planning.md               # 📝 Plan de implementación
├── implementation-status.md  # ⚙️ Estado actual de implementación
└── qa-report.md             # ✅ Resultados de QA y testing
```

Estos archivos se pueden sincronizar a Obsidian con `/obsidian-sync`.

---

## ⚙️ Stack y Preferencias

### JavaScript/TypeScript
**Frontend:**
- React, Next.js, Vite
- Tailwind CSS, shadcn/ui
- Zustand o Context API para state management
- React Query para data fetching

**Backend:**
- Express.js, NestJS, Node.js
- Prisma ORM
- tRPC para type-safe APIs

**Database:**
- PostgreSQL (preferido)
- MongoDB (para casos específicos)
- Redis (caching)

**Testing:**
- Jest o Vitest (unit tests)
- Playwright (e2e tests)
- Testing Library (componentes React)

**Tools:**
- ESLint, Prettier (o Biome)
- Husky, Lint-staged
- pnpm (package manager preferido)

**Infrastructure:**
- Docker, Docker Compose
- GitHub Actions (CI/CD)

### Convenciones de Código
- **Variables/funciones**: camelCase (`getUserData`)
- **Componentes React**: PascalCase (`UserProfile`)
- **Archivos**: kebab-case (`user-profile.tsx`)
- **Constantes**: UPPER_SNAKE_CASE (`API_BASE_URL`)
- **Directorios**: kebab-case (`user-management/`)

### Principios de Diseño
- SOLID principles
- Clean Architecture (cuando aplique)
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- YAGNI (You Aren't Gonna Need It)
- Separation of Concerns

---

## 📝 Integración con Obsidian

**Vault Path**: `~/Documents/Obsidian/dropbox`

### Estructura en Obsidian
```
Projects/
  ├── [project-name]/
  │   ├── notes/           # Notas generales del proyecto
  │   ├── sessions/        # Reportes de sesiones Claude (synced)
  │   ├── planning/        # Planes y arquitectura
  │   └── resources/       # Recursos y referencias
```

### Tags Usados
- `mcp/claude/session` - Notas de sesiones de Claude
- `project/[name]` - Proyecto específico
- `note/development` - Notas de desarrollo
- `note/planning` - Notas de planificación
- `note/qa` - Notas de QA

### MCP Server
Se usa `obsidian-mcp-server` para:
- Crear notas programáticamente
- Buscar en el vault
- Sincronizar reportes de sesión
- Mantener contexto del proyecto

---

## 📖 Documentación

### Docs as Code
- Documentación vive en el repositorio (`docs/`)
- Versionada junto con el código
- Actualizada automáticamente con `/docs update`
- Formato markdown con diagramas

### Arc42 (Proyectos complejos)
Para proyectos que requieren documentación exhaustiva:
- Template Arc42 completo
- Diagramas C4 con Structurizr DSL
- ADRs (Architecture Decision Records)
- Se genera con `/docs generate --format=arc42`

### Diagramas
- **C4 Model**: Context, Container, Component views (Structurizr DSL)
- **UML**: Sequence, Class, Activity diagrams (Mermaid)
- **Preferencia**: Diagramas como código (versionables, diffables)

---

## 🎯 Agentes (Contexto para Task Tool)

Los agentes NO son comandos ejecutables, son **definiciones de comportamiento** para usar con Task tool:

**Disponibles:**
- `planner.md` - Planificación estratégica
- `researcher.md` - Research profundo
- `qa-auditor.md` - Auditoría de calidad
- `architect.md` - Diseño de arquitectura

**Uso:** Los comandos de workflow invocan Task tool con el contexto de estos agentes cuando sea necesario.

---

## 🔧 Configuración Adicional

### Conventional Commits
Formato: `type(scope): description`

**Tipos:**
- `feat` - Nueva funcionalidad
- `fix` - Corrección de bug
- `docs` - Cambios en documentación
- `style` - Formato (no afecta funcionalidad)
- `refactor` - Refactoring sin cambios funcionales
- `test` - Tests
- `chore` - Build, dependencias, configuración
- `perf` - Mejoras de performance
- `ci` - CI/CD

### Optimización
- Conservación de tokens habilitada
- Context compression activo
- Cache inteligente
- Reuso de agentes cuando sea posible

---

## 💡 Tips de Uso

1. **Siempre empieza con `/workflow-init`** para crear estructura de reportes
2. **Research antes de planificar** - El research informa mejores decisiones
3. **Actualiza `/workflow-status` frecuentemente** durante implementación
4. **Usa `/workflow-qa` antes de finalizar** para verificar calidad
5. **Sincroniza a Obsidian** para mantener historial de proyectos
6. **Los reportes son versionables** - Commitealos junto con el código

---

## 📚 Referencias

- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **Conventional Commits**: https://www.conventionalcommits.org
- **Arc42**: https://arc42.org
- **C4 Model**: https://c4model.com
- **Structurizr DSL**: https://structurizr.com/dsl

---

*Última actualización: 2025-09-30*