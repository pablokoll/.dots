return {
  "saghen/blink.cmp",
  opts = {
    -- =========================================================================
    -- COMPLETION
    -- =========================================================================
    completion = {
      -- Comportamiento del menu
      menu = {
        auto_show = true, -- Mostrar automáticamente (default: true)

        -- Dibujado del menu
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", gap = 1 },
          },
        },
      },

      -- Documentación
      documentation = {
        auto_show = true, -- Mostrar documentación automáticamente
        auto_show_delay_ms = 500, -- Delay antes de mostrar (default: 500)
        window = {
          border = "rounded", -- rounded, single, double, shadow
        },
      },

      -- Comportamiento de ghost text (sugerencia inline gris)
      ghost_text = {
        enabled = true, -- Habilitar ghost text (preview inline)
      },
    },

    -- =========================================================================
    -- KEYMAP
    -- =========================================================================
    keymap = {
      preset = "none", -- Desactivar preset para usar keymaps personalizados

      -- Keymaps personalizados
      ["<C-space>"] = { "show", "hide" }, -- Mostrar/ocultar menu
      ["<C-e>"] = { "hide" }, -- Ocultar menu
      ["<Tab>"] = { "accept", "fallback" }, -- ACEPTAR con Tab
      ["<S-Tab>"] = { "snippet_forward", "fallback" }, -- Shift+Tab para siguiente placeholder de snippet
      ["<C-k>"] = { "select_prev", "fallback" }, -- Ctrl+k para ARRIBA
      ["<C-j>"] = { "select_next", "fallback" }, -- Ctrl+j para ABAJO
      ["<C-b>"] = { "select_prev", "fallback" }, -- Ctrl+b para ARRIBA (alternativa)
      ["<C-f>"] = { "select_next", "fallback" }, -- Ctrl+f para ABAJO (alternativa)
      ["<C-n>"] = { "select_next", "fallback" }, -- Ctrl+n para ABAJO (alternativa)
      ["<C-p>"] = { "select_prev", "fallback" }, -- Ctrl+p para ARRIBA (alternativa)
    },

    -- =========================================================================
    -- SOURCES (Fuentes de completado)
    -- =========================================================================
    sources = {
      -- Orden de prioridad de fuentes
      default = { "lsp", "path", "snippets", "buffer" },

      -- Obsidian sources solo en markdown (configurado manualmente para evitar
      -- problemas de timing con la auto-integración de obsidian.nvim)
      per_filetype = {
        markdown = { "obsidian", "obsidian_new", "obsidian_tags", "lsp", "path", "snippets", "buffer" },
      },

      -- Providers (configurar fuentes individuales)
      providers = {
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          score_offset = 100, -- Prioridad alta para LSP
          fallbacks = { "buffer" }, -- Si LSP no tiene resultados, usar buffer
        },
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          score_offset = 3,
        },
        snippets = {
          name = "Snippets",
          module = "blink.cmp.sources.snippets",
          score_offset = 80,
        },
        buffer = {
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
        },
        -- Obsidian providers (wiki links, tags, new notes)
        -- enabled() checks that obsidian.nvim is fully initialized before blink calls the source
        obsidian = {
          name = "obsidian",
          module = "obsidian.completion.sources.blink.refs",
          async = true,
          enabled = function()
            return _G.Obsidian ~= nil and _G.Obsidian.opts ~= nil
          end,
          -- blink filtra por label, que es "[[NoteName]]" — los corchetes
          -- rompen el fuzzy match. filterText le dice a blink que filtre
          -- solo contra el nombre limpio de la nota.
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              item.filterText = item.label:gsub("^%[%[", ""):gsub("%]%]$", "")
            end
            return items
          end,
        },
        obsidian_new = {
          name = "obsidian_new",
          module = "obsidian.completion.sources.blink.new",
          async = true,
          enabled = function()
            return _G.Obsidian ~= nil and _G.Obsidian.opts ~= nil
          end,
        },
        obsidian_tags = {
          name = "obsidian_tags",
          module = "obsidian.completion.sources.blink.tags",
          async = true,
          enabled = function()
            return _G.Obsidian ~= nil and _G.Obsidian.opts ~= nil
          end,
        },
      },
    },

    -- =========================================================================
    -- APPEARANCE (Apariencia)
    -- =========================================================================
    appearance = {
      use_nvim_cmp_as_default = false, -- Usar estilo de nvim-cmp (más tradicional)
      nerd_font_variant = "mono", -- mono, normal - usa íconos de nerd font

      -- Kind icons (íconos por tipo de completion)
      kind_icons = {
        Text = "󰉿",
        Method = "󰊕",
        Function = "󰊕",
        Constructor = "󰒓",
        Field = "󰜢",
        Variable = "󰆦",
        Class = "󱡠",
        Interface = "󱡠",
        Module = "󰅩",
        Property = "󰖷",
        Unit = "󰪚",
        Value = "󰦨",
        Enum = "󰦨",
        Keyword = "󰻾",
        Snippet = "󱄽",
        Color = "󰏘",
        File = "󰈔",
        Reference = "󰬲",
        Folder = "󰉋",
        EnumMember = "󰦨",
        Constant = "󰏿",
        Struct = "󱡠",
        Event = "󱐋",
        Operator = "󰪚",
        TypeParameter = "󰬛",
      },
    },

    -- =========================================================================
    -- SIGNATURE HELP (Ayuda de firma de funciones)
    -- =========================================================================
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
  },
}
