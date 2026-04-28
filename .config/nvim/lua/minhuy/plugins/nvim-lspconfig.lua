return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local filetypes = { "systemverilog", "verilog" }
    local root_markers = { "verible.filelist", ".rules.verible_lint", ".git" }

    if vim.lsp and vim.lsp.config and vim.lsp.enable then
      vim.lsp.config("verible", {
        cmd = { "verible-verilog-ls" },
        filetypes = filetypes,
        root_markers = root_markers,
        single_file_support = true,
        capabilities = capabilities,
      })
      vim.lsp.enable("verible")
      return
    end

    local lspconfig = require("lspconfig")
    local configs = require("lspconfig.configs")
    local util = require("lspconfig.util")

    if not configs.verible then
      configs.verible = {
        default_config = {
          cmd = { "verible-verilog-ls" },
          filetypes = filetypes,
          root_dir = util.root_pattern(table.unpack(root_markers)),
          single_file_support = true,
        },
      }
    end

    lspconfig.verible.setup({
      capabilities = capabilities,
    })
  end,
}
