-- gopls configuration
-- Fixes slow reload of local modules when go.mod changes
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            -- Better file watching for local module changes
            memoryMode = "DegradeClosed",
          },
        },
      },
    },
  },
  init = function()
    -- Reload gopls diagnostics when go.mod changes (local modules fix)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "go.mod",
      callback = function()
        local clients = vim.lsp.get_clients({ name = "gopls" })
        if #clients > 0 then
          vim.lsp.buf.execute_command({ command = "gopls.resetGoModDiagnostics" })
        end
      end,
    })
  end,
}
