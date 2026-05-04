return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local has_verible_lint = vim.fn.executable("verible-verilog-lint") == 1

    if not has_verible_lint then
      return
    end

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
        local filetype = vim.bo.filetype

        if filetype == "systemverilog" or filetype == "verilog" then
          lint.try_lint("verible")
        end
      end,
    })
  end,
}
