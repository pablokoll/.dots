-- Copy mode's nvim: copies go to Herdr by OSC 52. wl-copy's owner process dies with the pane.
local osc52 = require("vim.ui.clipboard.osc52")
local last = { {}, "v" }
local function copy(reg)
  local emit = osc52.copy(reg)
  return function(lines, regtype) last = { lines, regtype }; emit(lines) end
end
local function paste() return last end -- Herdr never answers OSC 52 reads
vim.g.clipboard = { name = "herdr-osc52", copy = { ["+"] = copy("+"), ["*"] = copy("*") }, paste = { ["+"] = paste, ["*"] = paste } }
vim.opt.clipboard = "unnamedplus"
vim.cmd("normal! G")
