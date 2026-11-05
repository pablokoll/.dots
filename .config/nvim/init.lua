-- Herdr desktop app terminal (HC_TERMINAL_ID): HERDR_* here leaked into herdr-core
-- from the herdr TUI pane it was first started in. Drop them, or herdr plugins
-- (splits resize, nav, clipboard) drive that TUI pane instead of this nvim.
-- ponytail: assumes herdr TUI isn't nested inside a herdr-app terminal.
if vim.env.HC_TERMINAL_ID and vim.env.HERDR_PANE_ID then
  for name in pairs(vim.fn.environ()) do
    if name:match("^HERDR_") then vim.env[name] = nil end
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
