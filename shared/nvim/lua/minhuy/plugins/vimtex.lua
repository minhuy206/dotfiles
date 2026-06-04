return {
  "lervag/vimtex",
  ft = { "tex", "plaintex", "bib" },
  init = function()
    local is_mac = vim.uv.os_uname().sysname == "Darwin"
    vim.g.vimtex_view_method = is_mac and "skim" or "zathura"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_mappings_prefix = "<localleader>"
  end,
}
