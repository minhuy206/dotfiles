return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local group = vim.api.nvim_create_augroup("MinhuyTreesitterStart", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        local buf = args.buf
        if vim.bo[buf].buftype ~= "" then
          return
        end

        local ok, lang = pcall(vim.treesitter.language.get_lang, vim.bo[buf].filetype)
        if not ok or not lang then
          return
        end

        pcall(vim.treesitter.start, buf, lang)
      end,
    })

    vim.treesitter.language.register("systemverilog", { "verilog", "systemverilog", "sv" })
  end,
}
