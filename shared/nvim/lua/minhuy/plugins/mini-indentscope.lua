return {
  "echasnovski/mini.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.bufremove").setup({})
    require("mini.indentscope").setup({})
  end,
}
