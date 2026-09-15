-- Companion shell under the Claude terminal: a plain zsh in the same worktree.
-- Appears/disappears together with the Claude split (bottom half of that
-- column), never steals focus, click into it to type. When Neovim follows
-- Claude to another worktree (:cd), the shell cd's too if it is idle.
--   <leader>at  toggle the shell (opens Claude first if needed)

local M = { buf = nil, job = nil, win = nil, claude_win = nil }

local function claude_buf()
  local term = package.loaded["claudecode.terminal"]
  return term and term.get_active_terminal_bufnr() or nil
end

local function alive()
  return M.buf ~= nil and vim.api.nvim_buf_is_valid(M.buf) and M.job ~= nil and vim.fn.jobwait({ M.job }, 0)[1] == -1
end

local function spawn()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    pcall(vim.api.nvim_buf_delete, M.buf, { force = true })
  end
  M.buf = vim.api.nvim_create_buf(false, false) -- unlisted: no tab in the bufferline
  vim.bo[M.buf].bufhidden = "hide"
  M.job = vim.api.nvim_buf_call(M.buf, function()
    return vim.fn.jobstart({ vim.o.shell }, { term = true, cwd = vim.fn.getcwd() })
  end)
end

local function win_valid()
  return M.win ~= nil and vim.api.nvim_win_is_valid(M.win)
end

-- Open the shell in the bottom half of `claude_win`'s column.
function M.show(claude_win)
  if not alive() then
    spawn()
  end
  M.claude_win = claude_win
  if win_valid() then
    return
  end
  M.win = vim.api.nvim_open_win(M.buf, false, {
    split = "below",
    win = claude_win,
    height = math.floor(vim.api.nvim_win_get_height(claude_win) / 2),
  })
end

function M.hide()
  if win_valid() then
    pcall(vim.api.nvim_win_close, M.win, true)
  end
  M.win = nil
end

function M.toggle()
  if win_valid() then
    return M.hide()
  end
  local cb = claude_buf()
  local cw = cb and vim.fn.bufwinid(cb) or -1
  if cw == -1 then
    vim.cmd("ClaudeCode") -- shows Claude; the shell follows via BufWinEnter
  else
    M.show(cw)
  end
end

-- cd the shell when Neovim's cwd changes, unless a command is running in it.
function M.cd(dir)
  if not alive() then
    return
  end
  local stat = vim.fn.system({ "ps", "-o", "stat=", "-p", tostring(vim.fn.jobpid(M.job)) })
  if not stat:find("+", 1, true) then -- "+" = shell is the foreground process, i.e. at its prompt
    return vim.notify("Shell is busy, left it where it was", vim.log.levels.INFO, { title = "Claude shell" })
  end
  vim.fn.chansend(M.job, "\21cd " .. vim.fn.shellescape(dir) .. "\n") -- \21 = Ctrl-U clears any typed text
end

local group = vim.api.nvim_create_augroup("claude_shell", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(ev)
    -- Deferred: on first open the plugin records its terminal buffer a tick after the window shows.
    vim.schedule(function()
      if ev.buf ~= claude_buf() then
        return
      end
      local w = vim.fn.bufwinid(ev.buf)
      if w ~= -1 then
        M.show(w)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(ev)
    if tonumber(ev.match) == M.claude_win then
      vim.schedule(M.hide)
    end
  end,
})

vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function()
    M.cd(vim.fn.getcwd())
  end,
})

return M
