-- Keep Neovim on the worktree/branch Claude Code is working in.
--
-- scripts/claude-follow.sh (a Claude Code hook) calls `sync(cwd)` over RPC after
-- Claude runs a tool or changes directory. We reload buffers that changed on
-- disk and, when Claude has moved to another worktree of the repository Neovim
-- is in, `:cd` there so Neo-tree, pickers and the statusline follow.
-- Other repositories are ignored.
--
-- :ClaudeFollow [dir]   pick a worktree (or jump to one)
-- <leader>gw            same picker; also clickable in the statusline

local M = {}

local function git(dir, ...)
  local out = vim.fn.systemlist({ "git", "-C", dir, ... })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return out[1]
end

local function first_line(path)
  local ok, lines = pcall(vim.fn.readfile, path, "", 1)
  return ok and lines[1] or nil
end

M.root = nil   -- worktree root of Neovim's cwd (nil outside a repo)
M.common = nil -- shared .git dir; identical for every worktree of one repo
M.last = nil   -- last cwd reported by Claude (for troubleshooting)

local function refresh_root()
  local cwd = vim.fn.getcwd()
  M.root = git(cwd, "rev-parse", "--show-toplevel")
  M.common = M.root and git(cwd, "rev-parse", "--path-format=absolute", "--git-common-dir") or nil
end

-- Current branch of a worktree root, read from .git without spawning git.
function M.branch(root)
  local dotgit = root .. "/.git"
  local st = vim.uv.fs_stat(dotgit)
  if not st then
    return nil
  end
  local gitdir = dotgit
  if st.type == "file" then -- linked worktree: ".git" is a pointer file
    gitdir = (first_line(dotgit) or ""):match("^gitdir:%s*(.-)%s*$") or dotgit
    if gitdir:sub(1, 1) ~= "/" then
      gitdir = root .. "/" .. gitdir
    end
  end
  local head = first_line(gitdir .. "/HEAD") or ""
  return head:match("^ref:%s*refs/heads/(.-)%s*$") or head:sub(1, 7)
end

-- Statusline: branch of the cwd, plus the worktree name when not in the main checkout.
function M.status()
  if not M.root then
    return ""
  end
  local text = " " .. (M.branch(M.root) or "?")
  local st = vim.uv.fs_stat(M.root .. "/.git")
  if st and st.type == "file" then
    text = text .. " ⋅ " .. vim.fn.fnamemodify(M.root, ":t")
  end
  return text
end

-- Make `dir` Neovim's cwd. Neo-tree is bound to cwd, so it follows.
function M.enter(dir)
  dir = vim.fn.fnamemodify(vim.fn.expand(dir), ":p"):gsub("/$", "")
  if vim.fn.isdirectory(dir) == 0 then
    return vim.notify("Not a directory: " .. dir, vim.log.levels.WARN)
  end
  vim.cmd("silent cd " .. vim.fn.fnameescape(dir)) -- silent: a typed :cd echoes the path, which prompts for Enter at cmdheight=0
  vim.notify((M.branch(dir) or "?") .. "\n" .. vim.fn.fnamemodify(dir, ":~"), vim.log.levels.INFO, { title = "Worktree" })
end

-- Called by the Claude Code hook with Claude's cwd. Returns "" because RPC needs a value.
function M.sync(cwd)
  M.last = cwd
  vim.schedule(function()
    pcall(vim.cmd.checktime) -- reload buffers Claude changed on disk
    if type(cwd) ~= "string" or vim.fn.isdirectory(cwd) == 0 or not M.root then
      return
    end
    local target = git(cwd, "rev-parse", "--show-toplevel")
    if not target or target == M.root then
      return
    end
    if git(cwd, "rev-parse", "--path-format=absolute", "--git-common-dir") ~= M.common then
      return -- Claude is in another repository: not ours to follow
    end
    M.enter(target)
  end)
  return ""
end

-- Picker over `git worktree list`; confirm = cd there.
function M.pick()
  if not M.root then
    return vim.notify("Not inside a git repository", vim.log.levels.WARN)
  end
  local items = {}
  local out = table.concat(vim.fn.systemlist({ "git", "-C", M.root, "worktree", "list", "--porcelain" }), "\n")
  for block in (out .. "\n\n"):gmatch("(.-)\n\n") do
    local path = block:match("^worktree ([^\n]+)")
    if path then
      local branch = block:match("\nbranch refs/heads/([^\n]+)") or "(detached)"
      items[#items + 1] = { text = branch .. " " .. path, branch = branch, path = path }
    end
  end
  Snacks.picker({
    title = "Git worktrees",
    items = items,
    layout = { preset = "select" },
    format = function(item)
      return {
        { item.path == M.root and "● " or "  ", "Special" },
        { item.branch, "Special" },
        { "  " .. vim.fn.fnamemodify(item.path, ":~"), "Comment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        M.enter(item.path)
      end
    end,
  })
end

vim.api.nvim_create_autocmd("DirChanged", {
  group = vim.api.nvim_create_augroup("claude_follow", { clear = true }),
  callback = refresh_root,
})
refresh_root()

vim.api.nvim_create_user_command("ClaudeFollow", function(o)
  if o.args ~= "" then
    M.enter(o.args)
  else
    M.pick()
  end
end, { nargs = "?", complete = "dir", desc = "Pick or enter a git worktree" })

return M
