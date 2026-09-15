vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver50",
  "r-cr:hor20",
  "o:hor50",
}

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.updatetime = 50
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.isfname:append("@-@")

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false

-- Neovim 0.12's underline handler uses strict line indexing before clamping
-- diagnostics. A stale diagnostic can therefore abort BufReadPost on file open.
if vim.version().major == 0 and vim.version().minor == 12 then
  local underline = vim.diagnostic.handlers.underline

  vim.diagnostic.handlers.underline = {
    show = function(namespace, bufnr, diagnostics, opts)
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local valid_diagnostics = vim.tbl_filter(function(diagnostic)
        return diagnostic.lnum >= 0 and diagnostic.lnum < line_count
      end, diagnostics)

      underline.show(namespace, bufnr, valid_diagnostics, opts)
    end,
    hide = underline.hide,
  }
end

local restore_cursor = vim.api.nvim_create_augroup("RestoreCursorPosition", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = restore_cursor,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local row = mark[1]

    if vim.bo.buftype ~= "" then
      return
    end

    if row > 1 and row <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.cmd.normal, { args = { [[g`"]] }, bang = true })
    end
  end,
})
