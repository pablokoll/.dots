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
    local herdr_nav = vim.fn.expand(
      "~/.config/herdr/plugins/github/vim-herdr-navigation-a8bf42123d81/editor/nvim.lua"
    )
    if vim.fn.filereadable(herdr_nav) == 1 then
      dofile(herdr_nav)
    end

    -- Herdr desktop app (herdr-core sets HC_TERMINAL_ID): the app catches
    -- <C-h/j/k/l>. Its retro-spaces mod reads the nvim.server label and calls
    -- `nvim --server <sock> --remote-expr "v:lua.HerdrNav('h')"` (instant, unlike
    -- `hc keys`, which holds keys ~3 s after any typing). "edge" → the app moves panes.
    if vim.env.HC_TERMINAL_ID and vim.env.HC_TERMINAL_ID ~= "" then
      _G.HerdrNav = function(key)
        -- Outside normal mode the key keeps its meaning (insert <C-h> = backspace…).
        if vim.api.nvim_get_mode().mode ~= "n" then
          vim.api.nvim_input("<C-" .. key .. ">")
          return "input"
        end
        local win = vim.api.nvim_get_current_win()
        if not pcall(vim.cmd.wincmd, key) then
          vim.api.nvim_input("<C-" .. key .. ">")
          return "input"
        end
        return vim.api.nvim_get_current_win() == win and "edge" or "moved"
      end
      -- Not from a nested :terminal nvim ($NVIM set).
      if not vim.env.NVIM then
        local function label(v) return vim.system({ "hc", "label", vim.env.HC_TERMINAL_ID, "nvim.server=" .. v }) end
        label(vim.v.servername)
        vim.api.nvim_create_autocmd("VimLeavePre", { callback = function() label(""):wait(500) end })
      end
      -- WSL: the app runs on Windows; the Linux herdr-app can't start here, so
      -- call the Windows CLI (it talks to the running app).
      local herdr_app = "herdr-app"
      if vim.fn.has("wsl") == 1 then
        local exe = vim.fn.glob("/mnt/c/Users/*/AppData/Local/Programs/herdr-app/herdr-app.exe", false, true)[1]
        if exe then
          herdr_app = exe
        end
      end
      for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
        vim.keymap.set("n", "<C-" .. key .. ">", function()
          local win = vim.api.nvim_get_current_win()
          vim.cmd("wincmd " .. key)
          if vim.api.nvim_get_current_win() == win then
            pcall(vim.system, { herdr_app, "do", "retro-spaces.edge-" .. dir })
          end
        end, { silent = true, desc = "Navigate " .. dir .. " (nvim / Herdr app)" })
      end
    end
  end,
}
