-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ── Git worktrees / follow Claude ──────────────────────────────────────────
vim.keymap.set("n", "<leader>gw", function() require("claude_follow").pick() end, { desc = "Git worktrees (follow Claude)" })
vim.keymap.set("n", "<leader>at", function() require("claude_shell").toggle() end, { desc = "Toggle shell under Claude" })

-- ── Mouse ──────────────────────────────────────────────────────────────────
-- Ctrl-click: go to definition (jumps straight there when unique).
vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse><Cmd>lua Snacks.picker.lsp_definitions()<CR>", { desc = "Go to definition (ctrl-click)" })

-- Clicking into a terminal (e.g. Claude) starts typing right away; dragging still selects text.
vim.keymap.set("n", "<LeftRelease>", function()
  return vim.bo.buftype == "terminal" and "<LeftRelease>i" or "<LeftRelease>"
end, { expr = true, desc = "Click into terminal → type" })

-- Herdr (terminal multiplexer) owns plain right-click for its pane menu; with
-- ui.right_click_passthrough_modifier set, ctrl/alt + right-click reaches nvim.
-- Treat those exactly like a plain right-click so the menu below opens.
vim.keymap.set({ "n", "v", "i" }, "<C-RightMouse>", "<RightMouse>", { desc = "Context menu" })
vim.keymap.set({ "n", "v", "i" }, "<M-RightMouse>", "<RightMouse>", { desc = "Context menu" })

-- Right-click menu (mousemodel=popup_setpos). Rebuilt so the useful items come first.
vim.cmd([[
  silent! aunmenu PopUp
  anoremenu PopUp.Go\ to\ definition        <Cmd>lua Snacks.picker.lsp_definitions()<CR>
  anoremenu PopUp.Find\ references          <Cmd>lua Snacks.picker.lsp_references()<CR>
  anoremenu PopUp.Rename\ symbol            <Cmd>lua vim.lsp.buf.rename()<CR>
  anoremenu PopUp.Code\ action              <Cmd>lua vim.lsp.buf.code_action()<CR>
  anoremenu PopUp.Format                    <Cmd>lua LazyVim.format({ force = true })<CR>
  anoremenu PopUp.Show\ diagnostic          <Cmd>lua vim.diagnostic.open_float()<CR>
  anoremenu PopUp.All\ diagnostics          <Cmd>Trouble diagnostics toggle<CR>
  anoremenu PopUp.-1-                       <Nop>
  anoremenu PopUp.Git\ blame\ line          <Cmd>Gitsigns blame_line<CR>
  anoremenu PopUp.Git\ blame\ file          <Cmd>Gitsigns blame<CR>
  anoremenu PopUp.-2-                       <Nop>
  vnoremenu PopUp.Cut                       "+x
  vnoremenu PopUp.Copy                      "+y
  nnoremenu PopUp.Paste                     "+gP
  vnoremenu PopUp.Paste                     "+P
  inoremenu PopUp.Paste                     <C-R>+
  nnoremenu PopUp.Select\ all               ggVG
  anoremenu PopUp.-3-                       <Nop>
  vnoremenu PopUp.Send\ selection\ to\ Claude   <Cmd>ClaudeCodeSend<CR>
  nnoremenu PopUp.Add\ file\ to\ Claude         <Cmd>lua vim.cmd(vim.bo.filetype == "neo-tree" and "ClaudeCodeTreeAdd" or "ClaudeCodeAdd %")<CR>
  anoremenu PopUp.Toggle\ Claude                <Cmd>ClaudeCode<CR>
  anoremenu PopUp.-4-                       <Nop>
  amenu     PopUp.Open\ in\ browser         gx
]])

-- Nvim's stock MenuPopup autocmd (runtime/lua/vim/_core/defaults.lua) toggles
-- items by their default names ("Open in web browser", "Show Diagnostics", ...).
-- Those no longer exist after the rebuild above, so it raised E329 on every
-- right-click and the menu never appeared. Drop it.
pcall(vim.api.nvim_del_augroup_by_name, "nvim.popupmenu")

-- ── Search ───────────────────────────────────────────────────────────────────
-- Cmd+Shift+F: Spotlight-style project search. Ghostty sends cmd+shift+f as
-- \x1bF (alt+shift+f); herdr forwards unbound alt keys, nvim sees <M-F>.
-- Live ripgrep, Enter jumps to file:line. In visual mode it searches the selection.
local spotlight = { preset = "vertical", layout = { row = 2, width = 0.6, min_width = 100, height = 0.7 } }
vim.keymap.set({ "n", "i", "t" }, "<M-F>", function()
  Snacks.picker.grep({ title = "Search project", layout = spotlight })
end, { desc = "Search project (cmd+shift+f)" })
vim.keymap.set("v", "<M-F>", function()
  Snacks.picker.grep_word({ title = "Search project", layout = spotlight })
end, { desc = "Search selection in project (cmd+shift+f)" })

-- Option-click: go to definition (same as ctrl-click). Cmd-click cannot reach
-- nvim: terminal mouse reporting has no bit for the cmd/super modifier.
vim.keymap.set("n", "<M-LeftMouse>", "<LeftMouse><Cmd>lua Snacks.picker.lsp_definitions()<CR>", { desc = "Go to definition (option-click)" })
