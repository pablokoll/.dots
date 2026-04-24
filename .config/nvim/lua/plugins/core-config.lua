-- ═══════════════════════════════════════════════════════════════════════════
-- LazyVim Core Configuration
-- ═══════════════════════════════════════════════════════════════════════════
-- Configuración base de LazyVim: colorscheme, opciones generales, etc.

return {
  -- ─────────────────────────────────────────────────────────────────────────
  -- LazyVim Core - Configuración principal
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "LazyVim/LazyVim",
    opts = {
      -- El colorscheme se configura en theme.lua (symlink a Omarchy)
      -- news = {
      --   lazyvim = true,
      --   neovim = true,
      -- },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- Tokyonight - Colorscheme por defecto de LazyVim
  -- ─────────────────────────────────────────────────────────────────────────
  -- Deshabilitado porque usamos el tema de Omarchy
  {
    "folke/tokyonight.nvim",
    enabled = false,
  },
}
