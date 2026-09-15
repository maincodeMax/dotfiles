-- Clickable buffer tabs: always visible, hover reveals the close button.
return {
  { "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        hover = { enabled = true, delay = 100, reveal = { "close" } },
      },
    },
  },
}
