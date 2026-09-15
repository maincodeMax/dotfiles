-- Claude Code inside Neovim (coder/claudecode.nvim). Speaks the same IDE protocol
-- as the VS Code extension: Claude sees your selection and open files, and can
-- open files and diffs here.
--   <leader>ac  toggle the Claude terminal (right split)
--   mouse       click "󰚩 claude" in the statusline, or right-click → Toggle Claude
--   <leader>as  send selection (visual) / add file (in Neo-tree)
return {
  { "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy", -- start the IDE server at startup so any `claude` can connect (/ide)
    opts = {
      -- Same flags as the shell alias. Drop --dangerously-skip-permissions to
      -- review Claude's edits as diffs inside Neovim before they land.
      terminal_cmd = vim.fn.expand("~/.local/bin/claude") .. " --dangerously-skip-permissions",
      terminal = {
        split_side = "right",
        split_width_percentage = 0.38,
      },
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file", ft = { "neo-tree", "snacks_picker_list" } },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
