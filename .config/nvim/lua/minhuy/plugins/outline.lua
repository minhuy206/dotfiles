return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("outline").setup({})
  end,
}
