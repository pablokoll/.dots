return {
  dir = "/home/pablo/.config/herdr/plugins/github/herdr-splits-d880c4924f2b",
  name = "herdr-splits.nvim",
  lazy = false,
  -- ponytail: only resize wired here, nav stays with vim-herdr-navigation
  -- (already bound). dir uses herdr's commit-hash plugin path; breaks on
  -- `herdr plugin update` — re-run `find ~/.config/herdr/plugins/github
  -- -maxdepth 1 -iname '*herdr-splits*'` and update when M-hjkl stops resizing.
  config = function()
    require("herdr-splits").setup()
  end,
  keys = {
    { "<M-h>", function() require("herdr-splits").resize_left() end, desc = "Resize left" },
    { "<M-j>", function() require("herdr-splits").resize_down() end, desc = "Resize down" },
    { "<M-k>", function() require("herdr-splits").resize_up() end, desc = "Resize up" },
    { "<M-l>", function() require("herdr-splits").resize_right() end, desc = "Resize right" },
  },
}
