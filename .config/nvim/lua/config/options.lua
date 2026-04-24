-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.wrap = true

-- ═════════════════════════════════════════════════════════════════════════
-- Swapfiles y Backups (deshabilitar para evitar conflictos)
-- ═════════════════════════════════════════════════════════════════════════
vim.opt.swapfile = false -- Deshabilitar swapfiles (evita E325: ATTENTION)
vim.opt.backup = false -- No crear backups automáticos
vim.opt.writebackup = false -- No crear backup antes de sobrescribir

-- Habilitar persistent undo (mejor alternativa a swapfiles)
vim.opt.undofile = true
vim.opt.undolevels = 10000 -- Más niveles de undo
