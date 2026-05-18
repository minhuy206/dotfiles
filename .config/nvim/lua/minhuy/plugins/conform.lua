return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local util = require("minhuy.util")
    local has_verible_format = util.has_exe("verible-verilog-format")
    local has_latexindent = util.has_exe("latexindent")
    local formatters_by_ft = {}

    if has_verible_format then
      formatters_by_ft.systemverilog = { "verible" }
      formatters_by_ft.verilog = { "verible" }
    end
    if has_latexindent then
      formatters_by_ft.tex = { "latexindent" }
    end

    local sv_fts = { "systemverilog", "verilog" }

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      format_on_save = function(bufnr)
        if has_verible_format and util.ft_in(bufnr, sv_fts) then
          return { lsp_format = "never", timeout_ms = 500 }
        end
        if has_latexindent and util.ft_in(bufnr, { "tex" }) then
          return { lsp_format = "never", timeout_ms = 1000 }
        end
      end,
    })
  end,
}
