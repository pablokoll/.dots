-- Paste images from clipboard into markdown
return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown" },
  opts = {
    default = {
      dir_path = function()
        return vim.fn.expand("~/Dropbox/Aplicaciones/remotely-save/personal-vault/Archive/Sources")
      end,
      file_name = "Pasted image %Y%m%d%H%M%S",
      extension = "png",
      use_absolute_path = false,
      relative_to_current_file = false,

      -- Build path relative to vault root so links work from any subdirectory
      template = function(args)
        local vault = vim.fn.expand("~/Dropbox/Aplicaciones/remotely-save/personal-vault")
        local rel_path = args.file_path:gsub("^" .. vim.pesc(vault) .. "/", "")
        return "![" .. args.cursor .. "](" .. rel_path .. ")"
      end,

      prompt_for_file_name = false,
      show_dir_path_in_prompt = false,
      drag_and_drop = {
        enabled = true,
        insert_mode = true,
      },
    },
  },
  keys = {
    { "<leader>oi", "<cmd>PasteImage<cr>", desc = "Paste image" },
  },
}
