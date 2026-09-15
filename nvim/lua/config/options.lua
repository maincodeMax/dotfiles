-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Mouse: full IDE behaviour. Click, drag, scroll, right-click menu (see keymaps.lua).
opt.mouse = "a"
opt.mousemodel = "popup_setpos" -- right-click = context menu at the click position
opt.mousescroll = "ver:2,hor:4"
opt.mousemoveevent = true     -- hover effects (bufferline close buttons)

-- Clean, minimal visual surface
opt.number = true
opt.relativenumber = false   -- off: cleaner look
opt.signcolumn = "yes:1"
opt.cursorline = true
opt.cursorlineopt = "number,line"
opt.showmode = false
opt.cmdheight = 0            -- hide cmd line when idle; pops up when typing
opt.laststatus = 3           -- one global statusline
opt.winbar = ""              -- no winbar
-- fillchars fields must be exactly one character (nvim 0.12+ rejects "").
opt.fillchars = {
  eob = " ",                 -- blank end-of-buffer (no ~ lines)
  fold = " ",
  foldopen = "▾",
  foldclose = "▸",
  foldsep = " ",
  diff = "╱",
  vert = "│",
  horiz = "─",
}
opt.pumblend = 10
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.shortmess:append("WIcC")

-- Disable snacks cursor animations for a quieter feel
vim.g.snacks_animate = false
