-- ═══════════════════════════════════════════════════════════════════════════
-- LazyVim Core Plugins Reference
-- ═══════════════════════════════════════════════════════════════════════════
-- Este archivo documenta todos los plugins que vienen por defecto con LazyVim
-- y te permite deshabilitarlos o personalizarlos según necesites.
--
-- LazyVim Version: 8+ (blink.cmp, snacks.picker)
--
-- 📝 Cómo usar este archivo:
-- 1. Los plugins están organizados por categoría
-- 2. Descomenta cualquier bloque para personalizar o deshabilitar
-- 3. Cada plugin tiene su descripción y opciones comunes
--
-- ⚠️ IMPORTANTE: Por defecto, todos están comentados (no hacen nada)
-- Solo descomenta lo que quieras modificar.

return {
  -- ═════════════════════════════════════════════════════════════════════════
  -- 💻 CODING PLUGINS
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- mini.pairs - Auto-cierra paréntesis, brackets, comillas, etc.
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "echasnovski/mini.pairs",
  --   enabled = false,  -- Deshabilitar si usas otro plugin de autopairs
  --   -- O personalizar:
  --   -- opts = {
  --   --   modes = { insert = true, command = false },
  --   --   skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- ts-comments.nvim - Comentarios inteligentes con treesitter
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "folke/ts-comments.nvim",
  --   enabled = false,  -- Si prefieres otro plugin de comentarios
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- mini.ai - Text objects extendidos (funciones, clases, argumentos, etc.)
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: af/if (función), ac/ic (clase), aa/ia (argumento)
  -- {
  --   "echasnovski/mini.ai",
  --   enabled = false,  -- Si no usas text objects avanzados
  --   -- O personalizar:
  --   -- opts = function(_, opts)
  --   --   -- Agregar custom text objects aquí
  --   -- end,
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- lazydev.nvim - Configuración de LuaLS para Neovim development
  -- ─────────────────────────────────────────────────────────────────────────
  -- Solo se carga para archivos .lua
  -- {
  --   "folke/lazydev.nvim",
  --   enabled = false,  -- Si no editas configs de Neovim en Lua
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🎨 COLORSCHEMES
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- tokyonight.nvim - Colorscheme por defecto de LazyVim
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    enabled = false, -- Si usas otro colorscheme
    -- O personalizar:
    -- opts = {
    --   style = "storm", -- storm, night, moon, day
    -- },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- catppuccin - Colorscheme alternativo
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- O personalizar:
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
    },
  },

  -- ═════════════════════════════════════════════════════════════════════════
  -- ✏️ EDITOR PLUGINS
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- grug-far.nvim - Search and replace en múltiples archivos
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybinding: <leader>sr
  -- {
  --   "MagicDuck/grug-far.nvim",
  --   enabled = false,
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- flash.nvim - Navegación rápida con labels (como easymotion)
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: s (flash), S (treesitter)
  -- {
  --   "folke/flash.nvim",
  --   enabled = false,  -- Usa leap.nvim extra como alternativa
  --   -- O personalizar keybindings:
  --   -- keys = {
  --   --   { "s", false },  -- Deshabilitar 's' default
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- which-key.nvim - Muestra popup con keybindings disponibles
  -- ─────────────────────────────────────────────────────────────────────────
  -- ⚠️ NO recomendado deshabilitar - es core para UX de LazyVim
  -- {
  --   "folke/which-key.nvim",
  --   -- Personalizar (NO deshabilitar):
  --   -- opts = {
  --   --   preset = "helix",  -- o "classic", "modern", "helix"
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- gitsigns.nvim - Indicadores de cambios de Git
  -- ─────────────────────────────────────────────────────────────────────────
  -- Muestra +/-/~ en sign column, stage/unstage hunks, etc.
  {
    "lewis6991/gitsigns.nvim",
    -- enabled = false, -- Si no usas Git
    -- O personalizar:
    opts = {
      current_line_blame = true, -- Mostrar blame en línea actual
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- trouble.nvim - Lista bonita de diagnostics, references, quickfix
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: <leader>xx (diagnostics), <leader>cs (symbols)
  -- {
  --   "folke/trouble.nvim",
  --   enabled = false,
  --   -- O personalizar:
  --   -- opts = {
  --   --   position = "bottom",  -- o "top", "left", "right"
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- todo-comments.nvim - Highlight de TODO, HACK, BUG, etc.
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: ]t (next TODO), <leader>st (search TODOs)
  -- {
  --   "folke/todo-comments.nvim",
  --   enabled = false,
  --   -- O personalizar keywords:
  --   -- opts = {
  --   --   keywords = {
  --   --     CUSTOM = { icon = " ", color = "hint" },
  --   --   },
  --   -- },
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🔧 LSP PLUGINS
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- nvim-lspconfig - Configuración de LSP servers
  -- ─────────────────────────────────────────────────────────────────────────
  -- ⚠️ NO deshabilitar - es core para IDE features
  -- {
  --   "neovim/nvim-lspconfig",
  --   -- Personalizar servers:
  --   -- opts = {
  --   --   servers = {
  --   --     lua_ls = {
  --   --       settings = {
  --   --         Lua = {
  --   --           diagnostics = { globals = { "vim" } },
  --   --         },
  --   --       },
  --   --     },
  --   --   },
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- mason.nvim - Package manager para LSP, linters, formatters
  -- ─────────────────────────────────────────────────────────────────────────
  -- Comando: :Mason
  -- {
  --   "williamboman/mason.nvim",
  --   enabled = false,  -- Solo si instalas herramientas manualmente
  --   -- O agregar herramientas:
  --   -- opts = {
  --   --   ensure_installed = {
  --   --     "stylua",
  --   --     "prettier",
  --   --     "eslint_d",
  --   --   },
  --   -- },
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 📝 FORMATTING & LINTING
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- conform.nvim - Async formatting engine
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "stevearc/conform.nvim",
  --   enabled = false,  -- Si solo usas formateo con LSP
  --   -- O agregar formatters:
  --   -- opts = {
  --   --   formatters_by_ft = {
  --   --     javascript = { "prettier" },
  --   --     python = { "black" },
  --   --   },
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- nvim-lint - Async linting engine
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "mfussenegger/nvim-lint",
  --   enabled = false,  -- Si solo usas diagnósticos con LSP
  --   -- O agregar linters:
  --   -- opts = {
  --   --   linters_by_ft = {
  --   --     javascript = { "eslint" },
  --   --     python = { "ruff" },
  --   --   },
  --   -- },
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🌲 TREESITTER PLUGINS
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- nvim-treesitter - Syntax highlighting avanzado
  -- ─────────────────────────────────────────────────────────────────────────
  -- ⚠️ NO deshabilitar - es core para LazyVim
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   -- Agregar lenguajes:
  --   -- opts = function(_, opts)
  --   --   vim.list_extend(opts.ensure_installed, {
  --   --     "rust",
  --   --     "go",
  --   --     "bash",
  --   --   })
  --   -- end,
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- nvim-treesitter-textobjects - Text objects con treesitter
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: ]f/[f (función), ]c/[c (clase), ]a/[a (argumento)
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   enabled = false,
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- nvim-ts-autotag - Auto-cierra y renombra tags HTML/JSX
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "windwp/nvim-ts-autotag",
  --   enabled = false,  -- Si no trabajas con HTML/JSX
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🎨 UI PLUGINS
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- bufferline.nvim - Tab/buffer line con iconos
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: Shift+h/l (ciclar buffers)
  -- {
  --   "akinsho/bufferline.nvim",
  --   enabled = false,  -- Si prefieres tabs nativas o barbar.nvim
  --   -- O personalizar:
  --   -- opts = {
  --   --   options = {
  --   --     always_show_bufferline = false,
  --   --   },
  --   -- },
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- lualine.nvim - Statusline rápida y personalizable
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   enabled = false,
  --   -- O cambiar theme:
  --   -- opts = function(_, opts)
  --   --   opts.options.theme = "auto"
  --   -- end,
  -- },

  -- ─────────────────────────────────────────────────────────────────────────
  -- noice.nvim - Mejora UI de mensajes, cmdline y popupmenu
  -- ─────────────────────────────────────────────────────────────────────────
  -- {
  --   "folke/noice.nvim",
  --   enabled = false,  -- Si prefieres UI nativa de Neovim
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🛠️ UTILITY PLUGINS
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- persistence.nvim - Gestión de sesiones
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: <leader>qs (restore session)
  -- {
  --   "folke/persistence.nvim",
  --   enabled = false,  -- Si no usas sesiones
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🚀 CORE DEPENDENCIES (NO DESHABILITAR)
  -- ═════════════════════════════════════════════════════════════════════════

  -- Los siguientes plugins son dependencias críticas de LazyVim.
  -- NO los deshabilites a menos que sepas exactamente qué estás haciendo:
  --
  -- • lazy.nvim - Plugin manager (requerido)
  -- • snacks.nvim - Core utilities (requerido)
  -- • plenary.nvim - Lua utility library (requerido por muchos plugins)
  -- • nui.nvim - UI component library (requerido por neo-tree, noice, etc.)
  -- • mini.icons - Icon provider (requerido por UI plugins)
  --
  -- ⚠️ NO agregues bloques para deshabilitar estos plugins.

  -- ═════════════════════════════════════════════════════════════════════════
  -- 💬 COMPLETION ENGINE (v8+)
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- blink.cmp - Motor de completado (default en LazyVim v8+)
  -- ─────────────────────────────────────────────────────────────────────────
  -- Si prefieres nvim-cmp, deshabilita este y habilita el extra nvim-cmp
  -- {
  --   "saghen/blink.cmp",
  --   enabled = false,  -- Solo si usas nvim-cmp extra
  --   -- O personalizar:
  --   -- opts = {
  --   --   sources = {
  --   --     default = { "lsp", "path", "snippets", "buffer" },
  --   --   },
  --   -- },
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 🔍 PICKER (v8+)
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- snacks.picker - Picker integrado en snacks.nvim (default)
  -- ─────────────────────────────────────────────────────────────────────────
  -- Si prefieres Telescope o fzf-lua, habilita esos extras
  {
    "folke/snacks.nvim",
    -- Para deshabilitar solo el picker:
    opts = {
      --   picker = { enabled = false },
      scroll = {
        enabled = false,
      },
    },
    -- Nota: No deshabilites snacks.nvim completamente, otros features lo necesitan
  },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 📁 FILE EXPLORER (Extra)
  -- ═════════════════════════════════════════════════════════════════════════

  -- ─────────────────────────────────────────────────────────────────────────
  -- neo-tree.nvim - File explorer (si habilitaste el extra)
  -- ─────────────────────────────────────────────────────────────────────────
  -- Keybindings: <leader>fe (explorer), <leader>e (toggle)
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   enabled = false,  -- Si prefieres snacks.explorer o mini.files
  --   -- O personalizar:
  --   -- opts = {
  --   --   filesystem = {
  --   --     filtered_items = {
  --   --       hide_dotfiles = false,
  --   --       hide_gitignored = false,
  --   --     },
  --   --   },
  --   --   window = {
  --   --     width = 35,
  --   --   },
  --   -- },
  -- },

  -- ═════════════════════════════════════════════════════════════════════════
  -- 📊 RESUMEN
  -- ═════════════════════════════════════════════════════════════════════════
  --
  -- Total de plugins core: ~30-35
  --
  -- Categorías:
  -- • 4 Coding plugins (mini.pairs, ts-comments, mini.ai, lazydev)
  -- • 2 Colorschemes (tokyonight, catppuccin)
  -- • 6 Editor plugins (grug-far, flash, which-key, gitsigns, trouble, todo-comments)
  -- • 2 LSP plugins (lspconfig, mason)
  -- • 2 Formatting/Linting (conform, nvim-lint)
  -- • 3 Treesitter plugins (treesitter, textobjects, autotag)
  -- • 3 UI plugins (bufferline, lualine, noice)
  -- • 1 Utility (persistence)
  -- • 5 Core dependencies (lazy, snacks, plenary, nui, mini.icons)
  -- • 1 Completion (blink.cmp)
  -- • 1 Picker (snacks.picker)
  -- • 1 Explorer (neo-tree - si está habilitado)
  --
  -- ⚠️ Plugins que NO debes deshabilitar:
  -- • lazy.nvim, snacks.nvim, plenary.nvim, nui.nvim, mini.icons
  -- • nvim-lspconfig, nvim-treesitter
  -- • which-key.nvim (core para UX)
  --
  -- 💡 Para más información sobre cada plugin:
  -- • :Lazy - Ver lista de plugins instalados
  -- • :LazyExtras - Explorar extras disponibles
  -- • https://www.lazyvim.org/plugins - Documentación oficial
  --
  -- ═════════════════════════════════════════════════════════════════════════
}
