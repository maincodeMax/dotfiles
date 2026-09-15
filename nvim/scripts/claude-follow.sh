#!/bin/sh
# Claude Code hook (PostToolUse / CwdChanged): tell every running Neovim where
# Claude is working. Neovim decides whether to follow (same repository only) —
# see ~/.config/nvim/lua/claude_follow.lua. Fans out detached and always exits 0,
# so it can never block or slow Claude.
cwd=$(jq -r '(.new_cwd // .cwd) // empty | @json' 2>/dev/null) # CwdChanged carries new_cwd; other events only cwd
[ -n "$cwd" ] || exit 0
nvim_bin=$(command -v nvim || echo /opt/homebrew/bin/nvim)
(
  seen=""
  for sock in "$NVIM" "${TMPDIR:-/tmp}"/nvim."$USER"/*/nvim.*.0; do
    [ -S "$sock" ] || continue
    case " $seen " in *" $sock "*) continue ;; esac
    seen="$seen $sock"
    "$nvim_bin" --server "$sock" --remote-expr "v:lua.require('claude_follow').sync($cwd)" >/dev/null 2>&1 &
  done
  wait
) >/dev/null 2>&1 </dev/null &
exit 0
