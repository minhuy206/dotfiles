vim.g.mapleader = " "

vim.keymap.set("n", "<leader>o", "<cmd>Neotree focus<cr>")
-- move line up/down (visual)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- join line but keep cursor
vim.keymap.set("n", "J", "mzJ`z")

-- scroll and keep center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- search navigation keep center + open fold
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- format paragraph and keep cursor
vim.keymap.set("n", "=ap", "ma=ap'a")

-- restart LSP
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<CR>")

-- paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- delete without affecting register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- disable Ex mode
vim.keymap.set("n", "Q", "<nop>")

-- tmux integration
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>")
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")

-- quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

-- location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>sr", [[:.,$s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>sc", [[:.,$s/\<<C-r><C-w>\>/<C-r><C-w>/gcI<Left><Left><Left><Left>]])
vim.keymap.set("n", "<leader>ss", [[:.,$s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>s", [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- reload config
vim.keymap.set("n", "<leader><leader>", function()
  for name in pairs(package.loaded) do
    if name:match("^minhuy") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify("Neovim config reloaded")
end)

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", function()
  require("undotree").open({ command = "botright 30vnew" })
end, { desc = "Open undotree on right" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", {
      buffer = true,
      desc = "Toggle markdown preview",
    })
  end,
})
