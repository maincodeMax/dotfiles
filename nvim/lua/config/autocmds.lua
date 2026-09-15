-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Plain shell under the Claude terminal, follows the worktree (see lua/claude_shell.lua)
require("claude_shell")

-- snacks.nvim closes its terminal windows on ExitPre. If :qa was issued from
-- inside one of them (e.g. the Claude terminal), closing that window aborts the
-- quit and you have to :qa twice. Nvim kills the jobs on exit anyway, so drop
-- those handlers once we are actually quitting.
vim.api.nvim_create_autocmd("ExitPre", {
  group = vim.api.nvim_create_augroup("quit_with_snacks_terminals", { clear = true }),
  callback = function()
    for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "ExitPre" })) do
      if (au.group_name or ""):find("^snacks_win_") then
        pcall(vim.api.nvim_del_autocmd, au.id)
      end
    end
  end,
})

-- LazyVim hands vim.notify back to noice after snacks loads (lazyvim/plugins/init.lua),
-- but noice's notify is off in minimal-ui.lua, so vim.notify stayed Neovim's plain echo:
-- with cmdheight=0 every notification became a "Press ENTER" prompt. Route to the snacks
-- toast. Late-bound because LazyVim loads this file before snacks when nvim gets a file arg.
vim.notify = function(msg, level, opts)
  local snacks = package.loaded["snacks"]
  if snacks and snacks.did_setup then
    return snacks.notifier.notify(msg, level, opts)
  end
  return vim.api.nvim_echo({ { tostring(msg) } }, true, { err = level == vim.log.levels.ERROR })
end
