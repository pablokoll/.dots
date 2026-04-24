return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = function(_, opts)
        if not opts.file_types then
          opts.file_types = { "markdown" }
        end
        opts.file_types = vim.list_extend(opts.file_types, { "Avante" })
      end,
      ft = function(_, ft)
        vim.list_extend(ft, { "Avante" })
      end,
    },
  },
  opts = {
    -- Usar Claude Code CLI (tu cuenta Pro, sin API key ni rate limits)
    provider = "claude-code",
    mode = "legacy",
    input = {
      provider = "native",
    },
    acp_providers = {
      ["claude-code"] = {
        command = "/home/pablo/.local/share/mise/installs/node/25.0.0/bin/npx",
        args = { "-y", "-g", "@zed-industries/claude-agent-acp" },
        env = {
          NODE_NO_WARNINGS = "1",
          PATH = "/home/pablo/.local/share/mise/installs/node/25.0.0/bin:" .. os.getenv("PATH"),
          ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = "/home/pablo/.local/share/mise/installs/node/25.0.0/bin/claude",
          ACP_PERMISSION_MODE = "bypassPermissions",
        },
      },
    },

    -- Keymaps
    mappings = {
      ask = "<leader>aa",       -- Abrir chat / hacer pregunta
      edit = "<leader>ae",      -- Editar selección con IA
      refresh = "<leader>ar",   -- Refrescar respuesta
      focus = "<leader>af",     -- Enfocar ventana de Avante
      toggle = {
        default = "<leader>at", -- Toggle panel
        debug = "<leader>ad",   -- Toggle debug
        hint = "<leader>ah",    -- Toggle hints
        suggestion = "<leader>as", -- Toggle sugerencias
      },
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
    },

    -- Ventana lateral
    windows = {
      position = "right",
      wrap = true,
      width = 40,
      sidebar_header = {
        align = "center",
        rounded = true,
      },
    },
  },
}
