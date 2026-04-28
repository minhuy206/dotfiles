return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = "ToggleTerm",
  keys = {
    { "<leader>t", "<cmd>ToggleTerm<CR>", mode = "n", desc = "Toggle terminal" },
  },
  config = function()
    require("toggleterm").setup()
  end,
}
