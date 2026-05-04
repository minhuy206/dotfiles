return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local has_verible_format = vim.fn.executable("verible-verilog-format") == 1
    local formatters_by_ft = {}
    if has_verible_format then
      formatters_by_ft.systemverilog = { "verible" }
      formatters_by_ft.verilog = { "verible" }
    end

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      format_on_save = function(bufnr)
        local filetype = vim.bo[bufnr].filetype

        if has_verible_format and (filetype == "systemverilog" or filetype == "verilog") then
          return {
            lsp_format = "never",
            timeout_ms = 500,
          }
        end
      end,
    })
  end,
}
