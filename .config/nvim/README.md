# 🎯 Mi Configuración de LazyVim

Configuración personal de Neovim basada en [LazyVim](https://github.com/LazyVim/LazyVim).

---

## 📊 Estado Actual

### Core Configuration
- ✅ News alerts deshabilitadas
- ✅ Relative numbers activados
- ✅ Integración con Omarchy theme

### LazyExtras Habilitados

| Extra | Descripción | Archivo |
|-------|-------------|---------|
| `editor.neo-tree` | File explorer | `lua/plugins/extras.lua` |
| `lang.json` | JSON LSP + formatters | `lua/plugins/extras.lua` |
| `lang.python` | Python LSP + tools | `lua/plugins/extras.lua` |
| `lang.typescript` | TypeScript LSP + tools | `lua/plugins/extras.lua` |

### Plugins Personalizados

| Plugin | Descripción | Archivo |
|--------|-------------|---------|
| `vim-be-good` | Juego para practicar Vim motions | `lua/plugins/vim-be-good.lua` |
| `vim-tmux-navigator` | Navegación seamless entre Vim y Tmux | `lua/plugins/vim-tmux-navigation.lua` |

### Customizaciones

| Archivo | Propósito |
|---------|-----------|
| `core-config.lua` | Configuración base de LazyVim |
| `lazy-core.lua` | 📚 Referencia completa de plugins core (para personalizar/deshabilitar) |
| `lazy-extras.lua` | Imports de LazyExtras |
| `theme.lua` | Symlink a tema de Omarchy |
| `omarchy-theme-hotreload.lua` | Hot-reload del tema |
| `snacks-animated-scrolling-off.lua` | Deshabilita animaciones de scroll |

---

## 📁 Estructura

```
~/.config/nvim/
├── init.lua                          # Entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua             # Autocommands personalizados
│   │   ├── keymaps.lua              # Keymaps personalizados
│   │   ├── lazy.lua                 # Setup de lazy.nvim
│   │   └── options.lua              # Opciones de Neovim
│   └── plugins/
│       ├── README.md                # 📚 Guía completa de plugins
│       ├── template-plugin.lua.example  # Template para nuevos plugins
│       ├── core-config.lua          # Config base de LazyVim
│       ├── lazy-core.lua            # 📋 Referencia de todos los plugins core
│       ├── lazy-extras.lua          # LazyExtras imports
│       ├── vim-be-good.lua          # Plugin: vim-be-good
│       ├── vim-tmux-navigation.lua  # Plugin: tmux navigator
│       └── [otros plugins...]
├── lazy-lock.json                    # Lockfile de versiones
└── lazyvim.json                      # Extras habilitados (auto-generado)
```

---

## 🚀 Cómo Agregar Plugins

### Método 1: LazyExtras (Recomendado si existe)

```vim
:LazyExtras
```

Presiona `x` para habilitar/deshabilitar extras.

### Método 2: Plugin Custom

Crea un archivo en `lua/plugins/`:

```lua
-- lua/plugins/mi-plugin.lua
return {
  "autor/nombre-plugin",
  opts = {
    -- Configuración aquí
  },
}
```

**💡 Tip:** Usa `lua/plugins/template-plugin.lua.example` como base.

**📖 Guía completa:** Ver `lua/plugins/README.md`

---

## 🎨 Próximos Pasos Sugeridos

### 1. Explorar LazyExtras

```vim
:LazyExtras
```

**Recomendados:**
- `lang.markdown` - Markdown support
- `lang.docker` - Docker support
- `coding.copilot` - GitHub Copilot
- `ui.mini-animate` - Smooth animations

### 2. Plugins Útiles a Considerar

**Comentarios inteligentes:**
```lua
-- lua/plugins/todo-comments.lua
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
}
```

**Auto-pairs:**
```lua
-- lua/plugins/nvim-autopairs.lua
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
}
```

**Zen mode:**
```lua
-- lua/plugins/zen-mode.lua
return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
  },
}
```

---

## 🔧 Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `:Lazy` | Abrir UI de plugins |
| `:LazyExtras` | Browser de extras |
| `:Lazy sync` | Actualizar plugins |
| `:Lazy clean` | Limpiar plugins no usados |
| `:Telescope keymaps` | Ver todos los keymaps |
| `:checkhealth lazy` | Diagnosticar problemas |

---

## 📚 Recursos

- **LazyVim Docs:** https://www.lazyvim.org/
- **Plugins Catalog:** https://www.lazyvim.org/plugins
- **Keymaps Reference:** https://www.lazyvim.org/keymaps
- **Extras Catalog:** https://www.lazyvim.org/extras
- **lazy.nvim Docs:** https://lazy.folke.io/

---

## 💡 Tips

1. **Un archivo por plugin** - Facilita organización
2. **Nombres descriptivos** - `telescope.lua` > `plugin1.lua`
3. **Usa lazy-loading** - Mejor performance
4. **Comenta tus configs** - Ayuda a tu yo del futuro
5. **`opts` > `config`** - Más simple cuando es suficiente

---

*Última actualización: 2024-12-04*
