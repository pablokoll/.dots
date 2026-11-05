-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Ctrl+P: file finder (alias for <space><space>)
vim.keymap.set("n", "<C-p>", function() Snacks.picker.files() end, { desc = "Find Files (Ctrl+P)" })

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

-- ═══════════════════════════════════════════════════════════════════════════
-- Habitica (habitica-sync ⇄ vault Area/Habitica.md)
-- ═══════════════════════════════════════════════════════════════════════════
local habitica_note = vim.fn.expand("~/Dropbox/Aplicaciones/remotely-save/personal-vault/Area/Habitica.md")

vim.keymap.set("n", "<leader>hs", function()
  -- Save the note first so its checks and new lines go up, then reload what came down.
  local buf = vim.fn.bufnr(habitica_note)
  if buf ~= -1 and vim.bo[buf].modified then
    vim.api.nvim_buf_call(buf, function() vim.cmd("silent write") end)
  end
  vim.notify("Habitica: syncing…")
  vim.system({ vim.fn.expand("~/.local/bin/habitica-sync") }, { text = true }, vim.schedule_wrap(function(r)
    if r.code ~= 0 then
      vim.notify("Habitica sync failed: " .. vim.trim(r.stderr or ""):match("[^\n]*$"), vim.log.levels.ERROR)
      return
    end
    vim.cmd("checktime")
    vim.notify("Habitica: synced")
  end))
end, { desc = "Habitica sync" })

vim.keymap.set("n", "<leader>ho", function() vim.cmd.edit(habitica_note) end, { desc = "Habitica note" })
