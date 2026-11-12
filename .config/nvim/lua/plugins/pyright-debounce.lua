return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {
        -- ponytail: pyright re-analyzes + reports LSP progress on every
        -- keystroke with no debounce, spamming a progress toast per char.
        -- Batch rapid didChange sends instead of hiding the notifications.
        flags = { debounce_text_changes = 500 },
      },
    },
  },
}
