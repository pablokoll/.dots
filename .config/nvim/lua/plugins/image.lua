-- View images inline in Neovim (requires Kitty or Ghostty terminal)
return {
  "3rd/image.nvim",
  enabled = false,
  ft = { "markdown" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    max_height_window_percentage = 50,
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        only_render_image_at_cursor = true, -- Only render when cursor is on image line
        download_remote_images = false,
      },
    },
  },
  keys = {
    {
      "<leader>oI",
      function()
        local line = vim.api.nvim_get_current_line()
        -- Match markdown image: ![...](path)
        local path = line:match("!%[.-%]%((.-)%)")
        if not path then
          vim.notify("No image found on current line", vim.log.levels.WARN)
          return
        end

        -- Get current file's directory as base
        local current_dir = vim.fn.expand("%:p:h")
        local full_path

        if path:match("^/") then
          -- Absolute path
          full_path = path
        elseif path:match("^~") then
          -- Home-relative path
          full_path = vim.fn.expand(path)
        else
          -- Relative to current file's directory
          full_path = current_dir .. "/" .. path
        end

        -- Check if file exists
        if vim.fn.filereadable(full_path) == 1 then
          vim.fn.system({ "xdg-open", full_path })
          vim.notify("Opening: " .. full_path, vim.log.levels.INFO)
        else
          vim.notify("File not found: " .. full_path, vim.log.levels.ERROR)
        end
      end,
      desc = "Open image in viewer",
    },
    {
      "<leader>ov",
      function()
        local image = require("image")
        vim.g.images_show_all = true
        image.setup({
          backend = "kitty",
          processor = "magick_cli",
          max_height_window_percentage = 50,
          integrations = {
            markdown = {
              enabled = true,
              clear_in_insert_mode = false,
              only_render_image_at_cursor = false,
              download_remote_images = false,
            },
          },
        })
        vim.cmd("edit")
        vim.notify("Showing all images", vim.log.levels.INFO)
      end,
      desc = "Show all images",
    },
  },
  config = function(_, opts)
    require("image").setup(opts)

    -- Always clear on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        require("image").clear()
      end,
    })

    -- Only clear on window/buffer leave when in cursor-only mode
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "BufWinLeave" }, {
      callback = function()
        if not vim.g.images_show_all then
          require("image").clear()
        end
      end,
    })

  end,
}
