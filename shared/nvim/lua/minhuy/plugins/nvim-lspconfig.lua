return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local util = require("minhuy.util")
    local caps = require("cmp_nvim_lsp").default_capabilities()

    local servers = {
      texlab = {
        cmd = { "texlab" },
        filetypes = { "tex", "plaintex", "bib" },
        root_markers = { ".latexmkrc", "latexmkrc", ".git" },
      },
      verible = {
        cmd = { "verible-verilog-ls" },
        filetypes = { "systemverilog", "verilog" },
        root_markers = { "verible.filelist", ".rules.verible_lint", ".git" },
        enable_if = "verible-verilog-ls",
      },
      tclint = {
        cmd = { "tclsp" },
        filetypes = { "sdc", "tcl", "upf", "xdc" },
        root_markers = { "tclint.toml", ".tclint", "pyproject.toml", ".git" },
        enable_if = "tclsp",
      },
    }

    for name, cfg in pairs(servers) do
      if not cfg.enable_if or util.has_exe(cfg.enable_if) then
        cfg.enable_if = nil
        cfg.single_file_support = true
        cfg.capabilities = caps
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end
    end
  end,
}
