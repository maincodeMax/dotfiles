-- Tokyo Night "night" — dark, calm, good contrast for long sessions
return {
  { "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        sidebars = "normal",
        floats = "normal",
      },
      on_highlights = function(hl, c)
        -- Thin subtle borders, muted line numbers, no harsh window separators
        hl.WinSeparator  = { fg = c.bg_highlight }
        hl.LineNr        = { fg = c.fg_gutter }
        hl.CursorLineNr  = { fg = c.orange, bold = true }
        hl.NeoTreeNormal = { bg = c.bg_dark }
        hl.NeoTreeNormalNC = { bg = c.bg_dark }
        hl.NeoTreeWinSeparator = { fg = c.bg_dark, bg = c.bg_dark }
        hl.StatusLine    = { bg = c.bg_dark }
      end,
    },
  },
  { "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-night" },
  },
}
