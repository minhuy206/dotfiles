-- next / prev tab
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
-- close buffer (mini.bufremove)
vim.keymap.set("n", "<leader>x", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Delete buffer" })

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
vim.keymap.set({ "n", "i", "v" }, "<C-z>", "<nop>")

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
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true })

-- reload config
vim.keymap.set("n", "<leader><leader>", function()
  require("minhuy.reload").reload()
end, { desc = "Reload Neovim config" })

vim.api.nvim_create_user_command("ConfigStatus", function()
  require("minhuy.reload").status()
end, { desc = "Show Neovim config load status", force = true })

vim.keymap.set("n", "<leader>u", function()
  vim.cmd("packadd nvim.undotree")
  require("undotree").open({ command = "botright 30vnew" })
end, { desc = "Open undotree on right" })

local remap_group = vim.api.nvim_create_augroup("MinhuyRemap", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = remap_group,
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", {
      buffer = true,
      desc = "Toggle markdown preview",
    })
  end,
})
