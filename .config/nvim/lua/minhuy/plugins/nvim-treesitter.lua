return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
      },
    })

    vim.treesitter.language.register("systemverilog", { "verilog", "systemverilog", "sv" })
  end,
}
