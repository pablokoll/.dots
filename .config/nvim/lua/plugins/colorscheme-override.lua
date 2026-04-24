return {
  {
    "folke/tokyonight.nvim",
    priority = 1001, -- higher than theme.lua (1000) so it wins
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
