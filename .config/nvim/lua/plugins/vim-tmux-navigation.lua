return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux Navigate Left", mode = "n" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux Navigate Down", mode = "n" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux Navigate Up", mode = "n" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux Navigate Right", mode = "n" },
  },
  init = function()
    vim.g.tmux_navigator_disable_when_zoomed = 1
    vim.g.tmux_navigator_save_on_switch = 2
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function()
    -- ponytail: hardcoded commit hash path from herdr's plugin dir;
    -- breaks on `herdr plugin update` (hash changes). Re-run
    -- `find ~/.config/herdr/plugins -iname nvim.lua` and update this path
    -- when C-hjkl stops crossing into herdr panes.
    dofile(vim.fn.expand(
      "~/.config/herdr/plugins/github/vim-herdr-navigation-a8bf42123d81/editor/nvim.lua"
    ))
  end,
}
