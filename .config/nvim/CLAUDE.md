# 📦 Plugins Directory

Esta carpeta contiene todas tus configuraciones de plugins para LazyVim.

## 📁 Estructura de Archivos

### Archivos Core (No modificar frecuentemente)

- **`core-config.lua`** - Configuración base de LazyVim (colorscheme, news alerts, etc.)
- **`extras.lua`** - Imports de LazyExtras (módulos pre-configurados)
- **`theme.lua`** - Symlink a tu tema de Omarchy
- **`omarchy-theme-hotreload.lua`** - Hot-reload del tema de Omarchy

### Archivos de Plugins Personalizados

Cada archivo `.lua` representa uno o más plugins relacionados:

- **`vim-be-good.lua`** - Plugin de entrenamiento de Vim
- **`vim-tmux-navigation.lua`** - Navegación entre Vim y Tmux
- **`snacks-animated-scrolling-off.lua`** - Deshabilita animaciones de scroll

### Archivos de Ejemplo

- **`example.lua`** - Ejemplos de configuración de LazyVim (referencia)
- **`all-themes.lua`** - Colección de temas disponibles

---

## 🚀 Cómo Agregar un Nuevo Plugin

### Opción 1: Plugin Simple (sin configuración)

Crea un archivo con el nombre del plugin:

```lua
-- lua/plugins/nombre-plugin.lua
return {
  "autor/nombre-plugin",
}
```

**Ejemplo: `lua/plugins/vim-sleuth.lua`**
```lua
return {
  "tpope/vim-sleuth",  -- Auto-detecta indentación
}
```

### Opción 2: Plugin con Configuración

```lua
-- lua/plugins/nombre-plugin.lua
return {
  "autor/nombre-plugin",

  -- Lazy loading (opcional pero recomendado)
  cmd = "ComandoPlugin",        -- Carga al ejecutar comando
  -- O
  keys = {                       -- Carga al presionar tecla
    { "<leader>x", "<cmd>Comando<cr>", desc = "Descripción" },
  },
  -- O
  event = "BufReadPre",          -- Carga en evento
  -- O
  ft = { "python", "lua" },      -- Carga en filetype

  -- Configuración
  opts = {
    opcion1 = true,
    opcion2 = "valor",
  },
}
```

**Ejemplo: `lua/plugins/todo-comments.lua`**
```lua
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "TodoTrouble", "TodoTelescope" },
  opts = {
    keywords = {
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      FIX = { icon = " ", color = "error" },
    },
  },
  keys = {
    { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search TODOs" },
  },
}
```

### Opción 3: Modificar Plugin Existente de LazyVim

Para modificar un plugin que ya viene con LazyVim:

```lua
-- lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",

  -- Extender configuración existente
  opts = function(_, opts)
    -- 'opts' contiene la config actual
    opts.defaults.layout_strategy = "horizontal"
    return opts
  end,

  -- Agregar o sobrescribir keymaps
  keys = {
    -- Deshabilitar un keymap default
    { "<leader>/", false },

    -- Agregar nuevo keymap
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
  },
}
```

---

## 📚 Patrones Comunes

### 1. Plugin con Dependencias

```lua
return {
  "plugin-principal",
  dependencies = {
    "plugin-requerido-1",
    "plugin-requerido-2",
  },
  opts = {},
}
```

### 2. Plugin con Build Step

```lua
return {
  "autor/plugin",
  build = "make",  -- O "npm install", etc.
  opts = {},
}
```

### 3. Plugin con Configuración Avanzada

Cuando necesitas más que solo `opts`:

```lua
return {
  "autor/plugin",
  config = function()
    local plugin = require("plugin")

    plugin.setup({
      -- Tu configuración
    })

    -- Código adicional post-setup
    plugin.load_extension("algo")
  end,
}
```

### 4. Múltiples Plugins Relacionados

```lua
-- lua/plugins/git.lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiff" },
  },
}
```

### 5. Plugin Condicional

```lua
return {
  "autor/plugin",
  enabled = function()
    return vim.fn.hostname() == "laptop-trabajo"
  end,
}
```

---

## 🔧 Opciones de Lazy Loading

**¿Por qué lazy-loading?** Para que Neovim inicie rápido, solo cargando plugins cuando los necesites.

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `cmd` | Carga al ejecutar comando | `cmd = "GitBlame"` |
| `keys` | Carga al presionar tecla | `keys = { "<leader>gg" }` |
| `ft` | Carga en filetype específico | `ft = { "python", "lua" }` |
| `event` | Carga en evento de Neovim | `event = "BufReadPre"` |
| `lazy = false` | Carga siempre al inicio | `lazy = false` |

**Eventos comunes:**
- `BufReadPre` - Antes de abrir archivo
- `BufEnter` - Al entrar a buffer
- `InsertEnter` - Al entrar a insert mode
- `VeryLazy` - Después de que Neovim termine de iniciar

---

## 🎨 Agregar un LazyExtra

Si el plugin que necesitas está disponible como LazyExtra:

**Opción 1: Interactiva**
```vim
:LazyExtras
# Navega y presiona 'x' para habilitar
```

**Opción 2: Programática**

Agrega a `extras.lua`:
```lua
{ import = "lazyvim.plugins.extras.lang.rust" },
```

---

## ❌ Deshabilitar Plugins

### Deshabilitar completamente

Crea `lua/plugins/disabled.lua`:
```lua
return {
  { "plugin/que-no-quiero", enabled = false },
}
```

### Deshabilitar solo keymaps

```lua
return {
  "plugin/nombre",
  keys = {
    { "<leader>x", false },  -- Deshabilita este keymap
  },
}
```

---

## 🧪 Testing de Plugins

Después de agregar un plugin:

1. **Reinicia Neovim** o ejecuta `:Lazy reload`
2. **Verifica instalación:** `:Lazy`
3. **Verifica salud:** `:checkhealth lazy`
4. **Prueba funcionalidad** del plugin

---

## 📖 Recursos

- **LazyVim Docs:** https://www.lazyvim.org/
- **lazy.nvim Docs:** https://lazy.folke.io/
- **Plugin Spec Reference:** https://lazy.folke.io/spec
- **LazyExtras Catalog:** https://www.lazyvim.org/extras

---

## 💡 Tips

1. **Un plugin por archivo** (facilita organización y git diffs)
2. **Nombres descriptivos** (`telescope.lua`, no `plugin1.lua`)
3. **Comenta tus configs** (tu yo del futuro te lo agradecerá)
4. **Lazy-load cuando puedas** (mejor performance)
5. **Usa `opts` en vez de `config`** cuando sea posible (más simple)
6. **Agrega `desc` a tus keymaps** (aparece en which-key)

---

## 🐛 Troubleshooting

**Plugin no se carga:**
- ¿Está en `lazy-lock.json`? → `:Lazy sync`
- ¿Tiene errores? → `:Lazy` (verás errores en rojo)
- ¿Lazy-loading mal configurado? → Prueba `lazy = false`

**Conflicto de keymaps:**
- Usa `:Telescope keymaps` para ver todos los keymaps
- Deshabilita el conflictivo con `{ "<key>", false }`

**Cambios no se aplican:**
- Reinicia Neovim completamente
- O ejecuta `:Lazy reload`

---

*Última actualización: 2024-12-04*
