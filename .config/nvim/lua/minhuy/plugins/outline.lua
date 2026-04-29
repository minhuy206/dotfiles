return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>O", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("outline").setup({
      outline_window = {
        position = "right",
        width = 25,
        relative_width = true,
        auto_close = false,
        auto_jump = false,
        focus_on_open = false,
      },
      outline_items = {
        show_symbol_details = true,
        show_symbol_lineno = true,
        auto_set_cursor = true,
      },
      preview_window = {
        auto_preview = false,
      },
    })
  end,
}
