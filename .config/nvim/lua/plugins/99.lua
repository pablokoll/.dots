-- ThePrimeagen/99 - AI Agent for Neovim
-- Requires: Claude Code CLI installed and configured
-- Docs: https://github.com/ThePrimeagen/99

return {
  "ThePrimeagen/99",
  dependencies = {
    "saghen/blink.cmp",
    { "saghen/blink.compat", version = "2.*" },
  },
  config = function()
    local ninety_nine = require("99")

    local Providers = require("99").Providers
    ninety_nine.setup({
      -- Use Claude Code as the provider (uses your Claude Pro account via CLI)
      provider = Providers.ClaudeCodeProvider,

      -- Logger configuration
      logger = {
        -- debug = true,
        -- path = "/tmp/99.log",
        -- print_errors = true,
      },

      -- Completion source
      completion = {
        source = "blink",
      },

      -- Custom rules: paths to folders with SKILL.md files
      -- custom_rules = {
      --   "/path/to/custom/rules",
      -- },

      -- Markdown files for context (defaults to "AGENT.md")
      md_files = { "AGENT.md", "CLAUDE.md" },
    })

    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Vibe: LLM-powered code suggestion/analysis on current buffer
    keymap("n", "<leader>av", function()
      ninety_nine.vibe()
    end, vim.tbl_extend("force", opts, { desc = "99: Vibe" }))

    -- Search: busca en el proyecto con un prompt
    keymap("n", "<leader>aj", function()
      ninety_nine.search()
    end, vim.tbl_extend("force", opts, { desc = "99: Search" }))

    -- Visual: procesa la selección visual
    keymap("v", "<leader>au", function()
      ninety_nine.visual()
    end, vim.tbl_extend("force", opts, { desc = "99: Process selection" }))

    -- Open: abre ventana con resultados anteriores
    keymap("n", "<leader>ao", function()
      ninety_nine.open()
    end, vim.tbl_extend("force", opts, { desc = "99: Open results" }))

    -- Stop: cancela todos los requests en vuelo
    keymap("n", "<leader>ax", function()
      ninety_nine.stop_all_requests()
    end, vim.tbl_extend("force", opts, { desc = "99: Stop all requests" }))

    -- Clear: limpia todos los requests anteriores
    keymap("n", "<leader>ac", function()
      ninety_nine.clear_previous_requests()
    end, vim.tbl_extend("force", opts, { desc = "99: Clear previous requests" }))

    -- Logs: ver logs de debug
    keymap("n", "<leader>al", function()
      ninety_nine.view_logs()
    end, vim.tbl_extend("force", opts, { desc = "99: View logs" }))

    -- Worker: set work para tracking persistente del proyecto
    keymap("n", "<leader>aw", function()
      local worker = ninety_nine.Extensions.Worker
      worker.set_work()
    end, vim.tbl_extend("force", opts, { desc = "99: Set work (Worker)" }))
  end,
}
