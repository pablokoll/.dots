-- ═══════════════════════════════════════════════════════════════════════════
-- Configuración de DAP para C/C++
-- ═══════════════════════════════════════════════════════════════════════════
-- Extiende el extra de DAP de LazyVim para soportar C/C++ con codelldb

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
          ensure_installed = { "codelldb" },
        },
      },
    },
    opts = function()
      local dap = require("dap")

      -- Configuración de codelldb para C/C++
      local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      -- Configuraciones de launch para C/C++
      dap.configurations.c = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            local filename = vim.fn.expand("%:t:r")
            local executable_path = cwd .. "/" .. filename

            if vim.fn.filereadable(executable_path) == 1 then
              return executable_path
            end

            return vim.fn.input("Path to executable: ", cwd .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- Usar la misma configuración para C++
      dap.configurations.cpp = dap.configurations.c
    end,
  },
}
