-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal mode: salir con Esc fácilmente
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ═══════════════════════════════════════════════════════════════════════════
-- Debug keymaps (VSCode style)
-- ═══════════════════════════════════════════════════════════════════════════
vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Debug: Start/Continue" })

vim.keymap.set("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

vim.keymap.set("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

vim.keymap.set("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

vim.keymap.set("n", "<S-F11>", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

vim.keymap.set("n", "<C-S-F5>", function()
  require("dap").restart()
end, { desc = "Debug: Restart" })

vim.keymap.set("n", "<S-F5>", function()
  require("dap").terminate()
end, { desc = "Debug: Stop" })

-- ═══════════════════════════════════════════════════════════════════════════
-- Insert mode keymaps
-- ═══════════════════════════════════════════════════════════════════════════
-- Ctrl+Backspace para borrar palabra hacia atrás (como en editores modernos)
-- Múltiples variantes para compatibilidad con diferentes terminales
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backwards" })
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word backwards" })
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backwards (Alt)" })

-- ═══════════════════════════════════════════════════════════════════════════
-- Paste from yank register (never overwritten by deletes)
-- ═══════════════════════════════════════════════════════════════════════════
vim.keymap.set({ "n", "v" }, "P", '"0p', { desc = "Paste from yank register (after cursor)" })

-- ═══════════════════════════════════════════════════════════════════════════
-- Replace keymaps
-- ═══════════════════════════════════════════════════════════════════════════
-- Flujo: * para buscar, luego <leader>rn (uno por uno) o <leader>rr (todos)

-- * busca sin saltar (queda en la ocurrencia actual)
vim.keymap.set("n", "*", "*N", { desc = "Search word under cursor (stay in place)" })

-- <leader>rn: reemplaza la ocurrencia actual y salta a la siguiente (cgn)
vim.keymap.set("n", "<leader>rn", "cgn", { desc = "Replace next occurrence (repeat with .)" })

-- <leader>rr: abre :%s/<palabra>/ listo para escribir el reemplazo
vim.keymap.set("n", "<leader>rr", function()
  local word = vim.fn.expand("<cword>")
  vim.fn.setreg("/", "\\<" .. word .. "\\>")
  vim.opt.hlsearch = true
  return ":%s/\\<" .. word .. "\\>/"
end, { desc = "Replace all occurrences of word under cursor", expr = true })

-- ═══════════════════════════════════════════════════════════════════════════
-- Spell checking keymaps
-- ═══════════════════════════════════════════════════════════════════════════
vim.keymap.set("n", "<leader>zs", function()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("Spell " .. (vim.opt.spell:get() and "enabled" or "disabled"))
end, { desc = "Toggle spell checking" })
vim.keymap.set("n", "<leader>zz", "z=", { desc = "Spell suggestions" })
vim.keymap.set("n", "<leader>zn", "]s", { desc = "Next misspelled word" })
vim.keymap.set("n", "<leader>zp", "[s", { desc = "Previous misspelled word" })
vim.keymap.set("n", "<leader>za", "zg", { desc = "Add word to dictionary" })
