return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local util = require("minhuy.util")
    local lint = require("lint")

    if not util.has_exe("verible-verilog-lint") then
      return
    end

    local sv_fts = { "systemverilog", "verilog" }

    lint.linters.verible = {
      cmd = "verible-verilog-lint",
      stdin = false,
      append_fname = true,
      ignore_exitcode = true,
      stream = "both",
      args = {
        "--lint_fatal=false",
        "--parse_fatal=false",
      },
      parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
        source = "verible",
        severity = vim.diagnostic.severity.WARN,
      }),
    }

    lint.linters_by_ft = {
      systemverilog = { "verible" },
      verilog = { "verible" },
    }

    local verible_lint = vim.api.nvim_create_augroup("VeribleLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = verible_lint,
      callback = function()
        if util.ft_in(0, sv_fts) then
          lint.try_lint("verible")
        end
      end,
    })
  end,
}
