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

  -- tokyonight habilitado en colorscheme-override.lua (priority 1001, gana a theme.lua)

}
