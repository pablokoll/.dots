-- ═══════════════════════════════════════════════════════════════════════════
-- Personalización de DAP UI
-- ═══════════════════════════════════════════════════════════════════════════
-- Extiende la configuración de LazyVim para tener una mejor visibilidad de la consola

return {
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 }, -- Consola de debug
          },
          size = 10,
          position = "bottom",
        },
      },
    },
  },
}
