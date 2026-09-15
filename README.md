# dotfiles

macOS setup: Neovim (LazyVim) wired to Claude Code, Ghostty, herdr, zsh, git.

```
nvim/               ~/.config/nvim
ghostty/config      ~/.config/ghostty/config
herdr/config.toml   ~/.config/herdr/config.toml
zsh/.zshrc          ~/.zshrc
zsh/.zprofile       ~/.zprofile
git/.gitconfig      ~/.gitconfig
zsh/zshenv.example  template for the untracked ~/.zshenv (tokens live there)
```

## Install

```sh
git clone git@github.com:maincodeMax/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh        # symlinks everything; existing files are backed up
```

Neovim plugins install themselves on first launch (lazy.nvim, versions pinned in `nvim/lazy-lock.json`).

## Neovim

Base is [LazyVim](https://lazyvim.github.io). What's on top:

**Look and feel.** tokyonight `night`. `cmdheight=0`, one global statusline, no dashboard, no noice popups, no indent guides/animations. Neo-tree is the only file tree, opens on launch when nvim starts with no file or a directory, single click opens files and toggles folders. Bufferline always visible with hover-to-close.

**Mouse.** Right-click opens a rebuilt context menu (go to definition, references, rename, code action, format, diagnostics, git blame, cut/copy/paste, send selection to Claude, toggle Claude). Ctrl-click or Option-click jumps to definition. Clicking into a terminal starts typing; dragging still selects. Statusline segments are clickable: branch opens the worktree picker, filename reveals in Neo-tree, `claude` toggles the Claude split, diagnostics opens Trouble.

**Claude Code integration** ([coder/claudecode.nvim](https://github.com/coder/claudecode.nvim)):

| Key | Action |
| --- | --- |
| `<leader>ac` | Toggle Claude terminal (right split, 38%) |
| `<leader>af` | Focus Claude |
| `<leader>ar` / `<leader>aC` | Resume / continue a session |
| `<leader>as` | Send selection (visual) or add file (in Neo-tree) |
| `<leader>ab` | Add current buffer |
| `<leader>aa` / `<leader>ad` | Accept / deny a diff |
| `<leader>at` | Toggle a plain zsh under the Claude split (same worktree, follows `:cd`) |
| `<leader>gw` | Git worktree picker (also click the branch in the statusline) |

**Follow Claude between worktrees.** `nvim/scripts/claude-follow.sh` is a Claude Code hook: after every tool call or directory change it tells each running nvim where Claude is. `lua/claude_follow.lua` reloads changed buffers and, if Claude moved to another worktree of the same repo, `:cd`s there so Neo-tree, pickers and the statusline follow. Wire it in `~/.claude/settings.json`:

```json
"PostToolUse": [
  { "matcher": "Bash|Edit|Write|MultiEdit|NotebookEdit|EnterWorktree|ExitWorktree",
    "hooks": [ { "type": "command", "command": "~/.config/nvim/scripts/claude-follow.sh", "async": true, "timeout": 10 } ] }
],
"CwdChanged": [
  { "hooks": [ { "type": "command", "command": "~/.config/nvim/scripts/claude-follow.sh", "async": true, "timeout": 10 } ] }
]
```

**Project search.** `Cmd+Shift+F` anywhere: Ghostty sends it as `alt+shift+f`, herdr forwards unbound alt keys, nvim binds `<M-F>` to a Spotlight-style live ripgrep picker (searches the selection in visual mode).

**Terminal buffers.** `Esc Esc` leaves terminal mode in the Claude split (snacks terminal). The companion zsh has no such map: use `Ctrl-\ Ctrl-n`.

## Ghostty and herdr

Ghostty routes Cmd shortcuts to herdr's prefix (`ctrl+space`): `Cmd+T/N/D/Shift+D/W` for tab, workspace, splits, close pane; `Cmd+[`/`]` tabs; `Cmd+arrows` focus panes. herdr owns plain right-click; `Ctrl`+right-click reaches nvim's menu.

## Secrets

`~/.zshenv` holds API tokens and is deliberately not in this repo. `zsh/zshenv.example` lists the variable names.
