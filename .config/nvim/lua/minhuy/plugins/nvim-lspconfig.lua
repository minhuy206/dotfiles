return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local verible_filetypes = { "systemverilog", "verilog" }
    local verible_root_markers = { "verible.filelist", ".rules.verible_lint", ".git" }
    local tcl_filetypes = { "sdc", "tcl", "upf", "xdc" }
    local tcl_root_markers = { "tclint.toml", ".tclint", "pyproject.toml", ".git" }
    local has_verible_ls = vim.fn.executable("verible-verilog-ls") == 1
    local has_tclsp = vim.fn.executable("tclsp") == 1

    if vim.lsp and vim.lsp.config and vim.lsp.enable then
      if has_verible_ls then
        vim.lsp.config("verible", {
          cmd = { "verible-verilog-ls" },
          filetypes = verible_filetypes,
          root_markers = verible_root_markers,
          single_file_support = true,
          capabilities = capabilities,
        })
        vim.lsp.enable("verible")
      end

      if has_tclsp then
        vim.lsp.config("tclint", {
          cmd = { "tclsp" },
          filetypes = tcl_filetypes,
          root_markers = tcl_root_markers,
          single_file_support = true,
          capabilities = capabilities,
        })
        vim.lsp.enable("tclint")
      end

      return
    end

    local lspconfig = require("lspconfig")
    local configs = require("lspconfig.configs")
    local util = require("lspconfig.util")

    if has_verible_ls then
      if not configs.verible then
        configs.verible = {
          default_config = {
            cmd = { "verible-verilog-ls" },
            filetypes = verible_filetypes,
            root_dir = util.root_pattern(table.unpack(verible_root_markers)),
            single_file_support = true,
          },
        }
      end

      lspconfig.verible.setup({
        capabilities = capabilities,
      })
    end

    if has_tclsp then
      if not configs.tclint then
        configs.tclint = {
          default_config = {
            cmd = { "tclsp" },
            filetypes = tcl_filetypes,
            root_dir = util.root_pattern(table.unpack(tcl_root_markers)),
            single_file_support = true,
          },
        }
      end

      lspconfig.tclint.setup({
        capabilities = capabilities,
      })
    end
  end,
}
