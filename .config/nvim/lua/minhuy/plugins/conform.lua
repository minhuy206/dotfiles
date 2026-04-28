return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        systemverilog = { "verible" },
        verilog = { "verible" },
      },
      format_on_save = function(bufnr)
        local filetype = vim.bo[bufnr].filetype

        if filetype == "systemverilog" or filetype == "verilog" then
          return {
            lsp_format = "never",
            timeout_ms = 500,
          }
        end
      end,
    })
  end,
}
