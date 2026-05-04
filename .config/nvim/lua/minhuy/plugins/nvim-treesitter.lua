return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local nvim_treesitter = require("nvim-treesitter")
    nvim_treesitter.setup({})
    nvim_treesitter.install({ "systemverilog", "tcl" })

    vim.filetype.add({
      extension = {
        sdc = "sdc",
        upf = "upf",
        xdc = "xdc",
      },
    })

    local group = vim.api.nvim_create_augroup("MinhuyTreesitterStart", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        local buf = args.buf
        if vim.bo[buf].buftype ~= "" then
          return
        end

        local max_filesize = 1024 * 1024 -- 1 MB
        local filename = vim.api.nvim_buf_get_name(buf)
        local stat = (vim.uv or vim.loop).fs_stat(filename)
        if stat and stat.size > max_filesize then
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
    vim.treesitter.language.register("tcl", { "sdc", "tcl", "upf", "xdc" })
  end,
}
