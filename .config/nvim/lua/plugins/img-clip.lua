-- Paste images from clipboard into markdown
return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown" },
  opts = {
    default = {
      -- Save images relative to current file's directory
      dir_path = "Archive/Sources",
      file_name = "Pasted image %Y%m%d%H%M%S",
      extension = "png",
      use_absolute_path = false,
      relative_to_current_file = false, -- relative to vault root

      -- Proper markdown image syntax
      template = "![$CURSOR]($FILE_PATH)",

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
