return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "Avante" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- Para iconos
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Solo renderizar en buffers markdown válidos
    file_types = { "markdown" },

    -- Renderizado más conservador para evitar errores
    render_modes = { "n", "c" }, -- Solo en normal y command mode

    -- Debounce para evitar renderizado excesivo
    debounce = 100,
    -- Renderizado de headings
    heading = {
      enabled = true,
      sign = true,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },

    -- Renderizado de code blocks
    code = {
      enabled = true,
      sign = true,
      style = "full",
      position = "left",
      width = "full",
      left_pad = 0,
      right_pad = 0,
    },

    -- Renderizado de listas
    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" },
      right_pad = 0,
      highlight = "RenderMarkdownBullet",
    },

    -- Renderizado de checkboxes (integración con Obsidian)
    checkbox = {
      enabled = true,
      unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" }, -- nf-md-checkbox_blank_outline
      checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" }, -- nf-md-checkbox_marked_circle_outline
      custom = {
        todo = { raw = "[-]", rendered = "󰔟 ", highlight = "RenderMarkdownTodo" }, -- nf-md-circle_outline
        right = { raw = "[>]", rendered = "󰁔 ", highlight = "DiagnosticWarn" }, -- nf-md-arrow_right_circle
        tilde = { raw = "[~]", rendered = "󰅖 ", highlight = "DiagnosticInfo" }, -- nf-md-close_circle_outline
      },
    },

    -- Renderizado de quotes
    quote = {
      enabled = true,
      icon = "▋",
      repeat_linebreak = false,
    },

    -- Renderizado de tablas
    pipe_table = {
      enabled = true,
      style = "full",
      cell = "padded",
      min_width = 0,
      border = {
        "┌", "┬", "┐",
        "├", "┼", "┤",
        "└", "┴", "┘",
        "│", "─",
      },
    },

    -- Callouts (bloques de Obsidian)
    callout = {
      note = { raw = "[!note]", rendered = "󰋽 Note", highlight = "DiagnosticInfo" },
      tip = { raw = "[!tip]", rendered = "󰌶 Tip", highlight = "DiagnosticOk" },
      important = { raw = "[!important]", rendered = "󰅾 Important", highlight = "DiagnosticHint" },
      warning = { raw = "[!warning]", rendered = "󰀪 Warning", highlight = "DiagnosticWarn" },
      caution = { raw = "[!caution]", rendered = "󰳦 Caution", highlight = "DiagnosticError" },
    },

    -- Links
    link = {
      enabled = true,
      image = "󰥶 ",
      hyperlink = "󰌹 ",
      highlight = "RenderMarkdownLink",
    },

    -- Signos en la columna de signos
    sign = {
      enabled = true,
      highlight = "RenderMarkdownSign",
    },

    -- Anti-conceal: mostrar contenido real al editar
    anti_conceal = {
      enabled = true,
    },

    -- Inline highlights (==texto==)
    inline_highlight = {
      enabled = true,
      highlight = "RenderMarkdownInlineHighlight",
    },

    -- Renderizado sin folding
    win_options = {
      conceallevel = { default = 3, rendered = 3 },
      concealcursor = { default = "n", rendered = "" },
    },
  },

  -- Configuración adicional para deshabilitar folding
  config = function(_, opts)
    -- Setup con manejo de errores
    local ok, render_markdown = pcall(require, "render-markdown")
    if not ok then
      vim.notify("Error loading render-markdown.nvim", vim.log.levels.ERROR)
      return
    end

    render_markdown.setup(opts)

    -- Configurar highlights personalizados
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        -- Checkbox marcado en verde brillante
        vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = "#10b981", bold = true })
        -- Checkbox desmarcado en gris
        vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = "#6b7280" })
        -- Highlight (==texto==) en amarillo suave
        vim.api.nvim_set_hl(0, "RenderMarkdownInlineHighlight", { bg = "#fef3c7", fg = "#92400e" }) -- Amarillo suavecito
        vim.api.nvim_set_hl(0, "@markup.highlight", { bg = "#fef3c7", fg = "#92400e" })
        vim.api.nvim_set_hl(0, "@text.emphasis", { bg = "#fef3c7", fg = "#92400e" })
      end,
    })

    -- Aplicar highlights inmediatamente
    vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = "#10b981", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = "#6b7280" })
    vim.api.nvim_set_hl(0, "RenderMarkdownInlineHighlight", { bg = "#fef3c7", fg = "#92400e" })
    vim.api.nvim_set_hl(0, "@markup.highlight", { bg = "#fef3c7", fg = "#92400e" })
    vim.api.nvim_set_hl(0, "@text.emphasis", { bg = "#fef3c7", fg = "#92400e" })

    -- Configurar folding por indentación en archivos markdown
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.foldenable = true -- Habilitar folding
        vim.opt_local.foldmethod = "indent" -- Folding por indentación
        vim.opt_local.shiftwidth = 2 -- Match 2-space indentation
        vim.opt_local.foldlevel = 99 -- Start with all folds open

        -- Evitar renderizado en buffers vacíos o muy pequeños
        local line_count = vim.api.nvim_buf_line_count(0)
        if line_count < 2 then
          vim.cmd("RenderMarkdown disable")
        end
      end,
    })
  end,
}
