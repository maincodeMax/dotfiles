# nvim

LazyVim-based config. See the repo root README for the full tour; the short version:

- `lua/config/options.lua` — mouse-first, `cmdheight=0`, single global statusline, no relative numbers.
- `lua/config/keymaps.lua` — right-click context menu, ctrl/option-click go-to-definition, `<M-F>` project search, worktree picker.
- `lua/plugins/minimal-ui.lua` — Neo-tree as the only file tree (single click opens), dashboard/noice popups off, minimal lualine with clickable segments.
- `lua/plugins/claude.lua` — `coder/claudecode.nvim`: Claude Code in a right split (`<leader>ac`).
- `lua/claude_follow.lua` + `scripts/claude-follow.sh` — nvim `:cd`s to whichever git worktree Claude Code is working in (driven by a Claude Code hook).
- `lua/claude_shell.lua` — companion zsh under the Claude split (`<leader>at`).
- `lua/plugins/colorscheme.lua` — tokyonight `night`.
