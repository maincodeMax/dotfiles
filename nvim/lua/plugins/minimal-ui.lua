-- Kill the visual clutter that ships with LazyVim.
-- Keep: Neo-tree, LSP, Treesitter, Telescope, git signs, mouse.
-- Remove: dashboard, noice popups, heavy statusline, animations.

return {
  -- No startup dashboard, no snacks file-explorer (Neo-tree is the only tree)
  { "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      explorer  = { enabled = false },   -- kill the second file-tree pane
      picker    = { sources = { explorer = { enabled = false } } },
      indent    = { enabled = false },
      scroll    = { enabled = false },
      animate   = { enabled = false },
      notifier  = { enabled = true, style = "minimal" },
      scope     = { enabled = false },
    },
  },

  -- Override LazyVim's <leader>e binding so it only toggles Neo-tree (not snacks)
  { "LazyVim/LazyVim",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>",        desc = "Explorer (Neo-tree)" },
      { "<leader>E", "<cmd>Neotree reveal<cr>",        desc = "Explorer focus current file" },
      { "<leader>fe", "<cmd>Neotree toggle<cr>",       desc = "Explorer" },
      { "<leader>fE", "<cmd>Neotree reveal<cr>",       desc = "Explorer focus current file" },
    },
  },

  -- Noice: keep command/search replacement but kill popups
  { "folke/noice.nvim",
    opts = {
      lsp = {
        progress = { enabled = false },
        hover    = { enabled = true },
        signature= { enabled = true },
      },
      messages = { enabled = false },
      notify   = { enabled = false },
      popupmenu = { enabled = true, backend = "nui" },
      presets = {
        bottom_search        = true,
        command_palette      = true,
        long_message_to_split= true,
        inc_rename           = false,
        lsp_doc_border       = false,
      },
    },
  },

  -- Lualine: minimal one-line statusline (no icons-spam, no pipeline)
  { "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_extend("force", opts.options or {}, {
        theme = "auto",
        section_separators = "",
        component_separators = "",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "snacks_dashboard" } },
      })
      -- Every component is clickable: branch → worktree picker, filename → reveal in
      -- tree, claude → toggle Claude terminal, diagnostics → Trouble.
      local function claude_connected()
        local cc = package.loaded["claudecode"]
        return cc ~= nil and cc.is_claude_connected()
      end
      opts.sections = {
        lualine_a = { { "mode", fmt = function(s) return s:sub(1, 1) end } },
        lualine_b = { {
          function() return require("claude_follow").status() end,
          on_click = function() require("claude_follow").pick() end,
        } },
        lualine_c = { { "filename", path = 1, on_click = function() vim.cmd("Neotree reveal") end } },
        lualine_x = {
          { function() return "󰚩 claude" end, color = { fg = "#9ece6a" }, cond = claude_connected,
            on_click = function() vim.cmd("ClaudeCode") end },
          { function() return "󰚩 claude" end, color = { fg = "#565f89" }, cond = function() return not claude_connected() end,
            on_click = function() vim.cmd("ClaudeCode") end },
          { "diagnostics", symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " },
            on_click = function() vim.cmd("Trouble diagnostics toggle") end },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      }
      opts.inactive_sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
      }
    end,
  },

  -- Neo-tree: narrow, clean, on left, auto-opens on startup
  { "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    opts = {
      enable_git_status = true,
      enable_diagnostics = false,
      window = {
        position = "left",
        width = 24,
        mappings = {
          ["<space>"] = "none",   -- let space lead work globally
          ["<LeftRelease>"] = "open", -- single click opens files / toggles folders
        },
      },
      default_component_configs = {
        indent = { padding = 0, with_markers = false },
        icon   = { folder_empty = "󰜌", folder_empty_open = "󰜌" },
        git_status = {
          symbols = {
            added    = "+",
            modified = "~",
            deleted  = "−",
            renamed  = "→",
            untracked= "?",
            ignored  = "",
            unstaged = "",
            staged   = "●",
            conflict = "!",
          },
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    },
    init = function()
      -- Auto-open Neo-tree when nvim launches with a directory or no args
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local arg = vim.fn.argv(0)
          local is_dir = type(arg) == "string" and arg ~= "" and vim.fn.isdirectory(arg) == 1
          local no_args = vim.fn.argc() == 0
          if is_dir or no_args then
            vim.schedule(function() vim.cmd("Neotree show") end)
          end
        end,
      })
    end,
  },
}
