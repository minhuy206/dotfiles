return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = function()
    local util = require("minhuy.util")
    local formatters_by_ft = {
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
    }

    if util.has_exe("stylua") then
      formatters_by_ft.lua = { "stylua" }
    end
    if util.has_exe("verible-verilog-format") then
      formatters_by_ft.systemverilog = { "verible" }
      formatters_by_ft.verilog = { "verible" }
    end
    if util.has_exe("latexindent") then
      formatters_by_ft.tex = { "latexindent" }
    end

    return {
      formatters = {
        prettier = {
          args = function(_, ctx)
            local args = { "--stdin-filepath", ctx.filename }
            if vim.bo[ctx.buf].filetype == "jsonc" then
              vim.list_extend(args, { "--parser", "json" })
            end
            return args
          end,
        },
      },
      formatters_by_ft = formatters_by_ft,
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    }
  end,
}
