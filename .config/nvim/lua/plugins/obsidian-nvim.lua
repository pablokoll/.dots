return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",

  -- ─────────────────────────────────────────────────────────────────────────
  -- Dependencies
  -- ─────────────────────────────────────────────────────────────────────────
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required
    "folke/snacks.nvim", -- For snacks.picker (already included in LazyVim)
    "nvim-treesitter/nvim-treesitter", -- For syntax highlighting
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- Init (configurar which-key group)
  -- ─────────────────────────────────────────────────────────────────────────
  init = function()
    -- Configurar el grupo de which-key para <leader>o
    vim.schedule(function()
      require("which-key").add({
        { "<leader>o", group = "obsidian", icon = "󰠮" },
      })
    end)
  end,

  -- ─────────────────────────────────────────────────────────────────────────
  -- Keymaps
  -- ─────────────────────────────────────────────────────────────────────────
  keys = {
    -- Quick note creation
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Obsidian note" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch notes" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search Obsidian" },

    -- Navigation
    { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Show links" },

    -- Daily notes
    { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Open today's note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Open yesterday's note" },
    { "<leader>om", "<cmd>Obsidian tomorrow<cr>", desc = "Open tomorrow's note" },

    -- Workspace
    { "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "Switch workspace" },

    -- Utilities
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
    { "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
    {
      "<leader>oT",
      function()
        local template_dir = vim.fn.expand("~/Dropbox/Aplicaciones/remotely-save/personal-vault/Resources/Templates")
        local templates = vim.fn.globpath(template_dir, "*.md", false, true)

        -- Extraer solo los nombres de archivo
        local template_names = {}
        for _, path in ipairs(templates) do
          local name = vim.fn.fnamemodify(path, ":t:r") -- Sin extensión
          table.insert(template_names, name)
        end

        -- Usar vim.ui.select (funciona con cualquier picker)
        vim.ui.select(template_names, {
          prompt = "Select template:",
        }, function(selected)
          if selected then
            vim.cmd("Obsidian template " .. vim.fn.fnameescape(selected))
            
            -- Limpiar frontmatters duplicados después de insertar template
            vim.defer_fn(function()
              local bufnr = vim.api.nvim_get_current_buf()
              local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              
              if lines[1] ~= "---" then
                return
              end
              
              -- Encontrar el primer frontmatter válido
              local first_fm_end = nil
              for i = 2, #lines do
                if lines[i] == "---" then
                  first_fm_end = i
                  break
                end
              end
              
              if not first_fm_end then
                return
              end
              
              -- Buscar YAML suelto después del primer frontmatter (insertado por template)
              -- El template puede insertar campos YAML sin --- de apertura
              local yaml_trash_end = first_fm_end
              local found_yaml_trash = false
              
              for i = first_fm_end + 1, #lines do
                local line = lines[i]
                
                -- Saltar líneas vacías
                if line:match("^%s*$") then
                  goto continue
                end
                
                -- Verificar si es una línea YAML (campo: valor o lista)
                if line:match("^%w+:%s*") or line:match("^%s*-%s") or line == "---" then
                  found_yaml_trash = true
                  yaml_trash_end = i
                  if line == "---" then
                    -- Encontramos el cierre del YAML basura
                    break
                  end
                else
                  -- Ya no es YAML, es contenido real
                  break
                end
                
                ::continue::
              end
              
              -- Si encontramos YAML basura, eliminarlo
              if found_yaml_trash and yaml_trash_end > first_fm_end then
                -- Extraer el primer frontmatter válido
                local valid_frontmatter = {}
                for i = 1, first_fm_end do
                  table.insert(valid_frontmatter, lines[i])
                end
                
                -- Obtener contenido real después del YAML basura
                local content_lines = {}
                local found_content = false
                
                for idx = yaml_trash_end + 1, #lines do
                  if not found_content and lines[idx]:match("^%s*$") then
                    goto skip
                  end
                  found_content = true
                  table.insert(content_lines, lines[idx])
                  ::skip::
                end
                
                -- Reconstruir buffer
                local final_lines = {}
                for _, line in ipairs(valid_frontmatter) do
                  table.insert(final_lines, line)
                end
                
                if #content_lines > 0 then
                  table.insert(final_lines, "")
                  for _, line in ipairs(content_lines) do
                    table.insert(final_lines, line)
                  end
                end
                
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, final_lines)
                vim.notify("Removed duplicate YAML from template", vim.log.levels.INFO)
              end
            end, 150) -- Esperar 150ms para que obsidian termine de insertar
          end
        end)
      end,
      desc = "Insert template",
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- Commands
  -- ─────────────────────────────────────────────────────────────────────────
  config = function(_, opts)
    require("obsidian").setup(opts)

    -- Comando para eliminar frontmatters duplicados (útil después de insertar templates)
    vim.api.nvim_create_user_command("ObsidianCleanFrontmatter", function()
      local bufnr = vim.api.nvim_get_current_buf()
      
      if not vim.bo[bufnr].modifiable then
        vim.notify("Buffer is not modifiable", vim.log.levels.ERROR)
        return
      end
      
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      if lines[1] ~= "---" then
        vim.notify("No frontmatter found", vim.log.levels.WARN)
        return
      end

      -- Detectar múltiples frontmatters
      local frontmatters = {}
      local i = 1
      
      while i <= #lines do
        if lines[i] == "---" then
          local fm_start = i
          local fm_end = nil
          
          for j = i + 1, #lines do
            if lines[j] == "---" then
              fm_end = j
              break
            end
          end
          
          if fm_end then
            table.insert(frontmatters, { start_line = fm_start, end_line = fm_end })
            i = fm_end + 1
          else
            break
          end
        else
          break
        end
      end

      -- Si solo hay un frontmatter, no hay nada que limpiar
      if #frontmatters == 1 then
        vim.notify("Only one frontmatter found, nothing to clean", vim.log.levels.INFO)
        return
      end

      -- Hay múltiples frontmatters - eliminar todos excepto el último (que es el del template)
      local last_frontmatter = frontmatters[#frontmatters]
      
      -- Extraer el frontmatter del template (el último)
      local template_frontmatter = {}
      for i = last_frontmatter.start_line, last_frontmatter.end_line do
        table.insert(template_frontmatter, lines[i])
      end

      -- Obtener contenido después del último frontmatter
      local content_lines = {}
      local found_content = false
      
      for idx = last_frontmatter.end_line + 1, #lines do
        if not found_content and lines[idx]:match("^%s*$") then
          goto continue
        end
        found_content = true
        table.insert(content_lines, lines[idx])
        ::continue::
      end

      -- Reconstruir buffer: solo el último frontmatter + contenido
      local final_lines = {}
      
      -- Agregar frontmatter del template
      for _, line in ipairs(template_frontmatter) do
        table.insert(final_lines, line)
      end
      
      -- Agregar contenido si existe
      if #content_lines > 0 then
        table.insert(final_lines, "")
        for _, line in ipairs(content_lines) do
          table.insert(final_lines, line)
        end
      end

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, final_lines)
      vim.notify("Duplicate frontmatter removed, kept template frontmatter", vim.log.levels.INFO)
    end, { desc = "Remove duplicate frontmatters, keep template" })
  end,

  -- ─────────────────────────────────────────────────────────────────────────
  -- Configuration
  -- ─────────────────────────────────────────────────────────────────────────
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    -- Disable legacy commands (new format for v4.0)
    legacy_commands = false,

    -- Workspaces
    workspaces = {
      {
        name = "dropbox",
        path = "~/Dropbox/Aplicaciones/remotely-save/personal-vault",
      },
    },

    -- Logging level (1-5, 1 = ERROR, 5 = TRACE)
    log_level = vim.log.levels.INFO,

    -- Daily notes configuration
    daily_notes = {
      folder = "Area/Journal",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = "Daily Note - Neovim.md", -- Template optimizado para Neovim
      default_tags = {}, -- No agregar tags automáticamente (se usan los del template)
    },

    -- Completion configuration
    -- Providers are configured directly in blink-cmp.lua to avoid timing issues
    completion = {
      nvim_cmp = false,
      blink = false, -- Disabled: providers registered manually in blink-cmp.lua
      min_chars = 2,
    },

    -- Note ID generation
    note_id_func = function(title)
      -- Si hay título, úsalo como ID; sino, usa timestamp
      if title ~= nil then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", "")
      else
        return tostring(os.time())
      end
    end,

    -- Note path function
    note_path_func = function(spec)
      -- Obtener el vault root (no usar spec.dir que es relativo)
      local vault_root = vim.fn.expand("~/Dropbox/Aplicaciones/remotely-save/personal-vault")

      -- Detectar si es una daily note (formato: YYYY-MM-DD)
      local is_daily_note = tostring(spec.id):match("^%d%d%d%d%-%d%d%-%d%d$")

      if is_daily_note then
        -- Daily notes van a Area/Journal
        return vault_root .. "/Area/Journal/" .. tostring(spec.id) .. ".md"
      else
        -- Notas normales van a Resources/Inbox
        return vault_root .. "/Resources/Inbox/" .. tostring(spec.id) .. ".md"
      end
    end,

    -- Callbacks para keymaps dentro de notas
    callbacks = {
      enter_note = function(note)
        -- Keymap para seguir links (gf)
        vim.keymap.set("n", "gf", function()
          return require("obsidian").util.gf_passthrough()
        end, { buffer = true, expr = true, desc = "Follow Obsidian link" })

        -- Keymap para toggle checkbox
        vim.keymap.set("n", "<leader>ch", "<cmd>ObsidianToggleCheckbox<cr>", {
          buffer = true,
          desc = "Toggle checkbox",
        })

        -- Autocommand para limpiar frontmatters duplicados, actualizar modified y reordenar
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = 0,
          callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            
            -- Verificar que el buffer es modificable
            if not vim.bo[bufnr].modifiable then
              return
            end
            
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

            -- Verificar que el archivo comienza con frontmatter (---)
            if lines[1] ~= "---" then
              return
            end

            -- Encontrar todos los frontmatters
            local frontmatters = {}
            local i = 1
            
            while i <= #lines do
              if lines[i] == "---" then
                local fm_start = i
                local fm_end = nil
                
                for j = i + 1, #lines do
                  if lines[j] == "---" then
                    fm_end = j
                    break
                  end
                end
                
                if fm_end then
                  table.insert(frontmatters, { start_line = fm_start, end_line = fm_end })
                  i = fm_end + 1
                else
                  break
                end
              else
                break
              end
            end

            if #frontmatters == 0 then
              return
            end

            local new_timestamp = os.date("!%Y-%m-%dT%H:%M:%S") .. "+01:00"
            
            -- Usar solo el último frontmatter (el del template si se insertó uno)
            local last_fm = frontmatters[#frontmatters]
            
            -- Parsear el frontmatter
            local function parse_frontmatter(start_line, end_line)
              local fm = {}
              local current_key = nil
              local in_multiline = false
              
              for line_idx = start_line + 1, end_line - 1 do
                local line = lines[line_idx]
                local list_match = line:match("^(%w+):%s*$")
                
                if list_match then
                  current_key = list_match
                  fm[current_key] = {}
                  in_multiline = true
                elseif in_multiline and line:match("^%s*-%s") then
                  local item = line:match("^%s*-%s*(.*)$")
                  table.insert(fm[current_key], item)
                elseif line:match("^(%w+):%s*(.+)$") then
                  local key, value = line:match("^(%w+):%s*(.+)$")
                  fm[key] = value
                  current_key = nil
                  in_multiline = false
                elseif line:match("^%w+:") then
                  local key = line:match("^(%w+):")
                  fm[key] = ""
                  current_key = nil
                  in_multiline = false
                else
                  current_key = nil
                  in_multiline = false
                end
              end
              
              return fm
            end
            
            local frontmatter = parse_frontmatter(last_fm.start_line, last_fm.end_line)
            
            -- Actualizar modified y created
            frontmatter.modified = new_timestamp
            if not frontmatter.created then
              frontmatter.created = new_timestamp
            end

            -- Reordenar frontmatter
            local ordered_keys = { "id", "tags", "aliases", "sources", "related", "keywords", "created", "modified" }
            local new_frontmatter = { "---" }

            local function format_value(key, value)
              if type(value) == "table" then
                if #value == 0 then
                  return key .. ": []"
                else
                  local result = { key .. ":" }
                  for _, item in ipairs(value) do
                    table.insert(result, "  - " .. item)
                  end
                  return result
                end
              else
                return key .. ": " .. tostring(value)
              end
            end

            for _, key in ipairs(ordered_keys) do
              if frontmatter[key] ~= nil then
                local formatted = format_value(key, frontmatter[key])
                if type(formatted) == "table" then
                  for _, line in ipairs(formatted) do
                    table.insert(new_frontmatter, line)
                  end
                else
                  table.insert(new_frontmatter, formatted)
                end
                frontmatter[key] = nil
              end
            end

            -- Campos extras alfabéticamente
            local extra_keys = {}
            for key, _ in pairs(frontmatter) do
              table.insert(extra_keys, key)
            end
            table.sort(extra_keys)

            for _, key in ipairs(extra_keys) do
              local formatted = format_value(key, frontmatter[key])
              if type(formatted) == "table" then
                for _, line in ipairs(formatted) do
                  table.insert(new_frontmatter, line)
                end
              else
                table.insert(new_frontmatter, formatted)
              end
            end

            table.insert(new_frontmatter, "---")

            -- Obtener contenido después del último frontmatter
            local content_lines = {}
            local found_content = false
            
            for idx = last_fm.end_line + 1, #lines do
              if not found_content and lines[idx]:match("^%s*$") then
                goto continue
              end
              found_content = true
              table.insert(content_lines, lines[idx])
              ::continue::
            end

            -- Reconstruir buffer
            local final_lines = {}
            for _, line in ipairs(new_frontmatter) do
              table.insert(final_lines, line)
            end
            
            if #content_lines > 0 then
              table.insert(final_lines, "")
              for _, line in ipairs(content_lines) do
                table.insert(final_lines, line)
              end
            end

            -- Reemplazar buffer
            local ok, err = pcall(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, final_lines)
            end)
            
            if not ok then
              vim.notify("Error updating frontmatter: " .. tostring(err), vim.log.levels.WARN)
            end
          end,
        })
      end,
    },

    -- Templates
    templates = {
      folder = "Resources/Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    -- Attachments (imágenes, PDFs, etc.)
    attachments = {
      folder = "Archive/Sources",
    },

    -- Picker configuration (usa snacks.picker)
    picker = {
      name = "snacks.picker",
    },

    -- Configuración de checkboxes (nuevo formato)
    checkbox = {
      order = { " ", "x", ">", "~" },
    },

    -- Footer configuration (deshabilitar para evitar errores con backlinks)
    footer = {
      enabled = false,
    },

    -- UI configuration (deprecado, usar render-markdown.nvim o markview.nvim)
    ui = {
      enable = false, -- Deshabilitar UI para evitar errores
    },

    -- Frontmatter configuration
    frontmatter = {
      enabled = true,
      sort = { "id", "tags", "aliases", "sources", "related", "keywords", "created", "modified" },
      func = function(note)
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%S") .. "+01:00"

        -- Campos base que siempre controlamos
        local out = {}

        -- 1. id (always lowercase)
        out.id = string.lower(tostring(note.id))

        -- 2. tags
        out.tags = note.tags or {}

        -- 3. aliases
        out.aliases = note.aliases or {}

        -- 4. created (preservar si existe, sino timestamp)
        if note.metadata ~= nil and note.metadata.created ~= nil then
          out.created = note.metadata.created
        else
          out.created = timestamp
        end

        -- 5. modified
        out.modified = timestamp

        -- 6. Preservar TODOS los campos adicionales del metadata (templates)
        -- Campos comunes de templates: sources, author, related, source, published, read
        if note.metadata ~= nil then
          for k, v in pairs(note.metadata) do
            -- Solo agregar si no existe ya en out
            if out[k] == nil then
              out[k] = v
            end
          end
        end

        -- 7. Campos específicos para daily notes
        local is_daily_note = tostring(note.id):match("^%d%d%d%d%-%d%d%-%d%d$")
        if is_daily_note then
          if out.mood == nil then
            out.mood = ""
          end
          if out.energy == nil then
            out.energy = ""
          end
        end

        return out
      end,
    },
  },
}
