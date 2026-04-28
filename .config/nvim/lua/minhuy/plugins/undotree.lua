return {
  "mbbill/undotree",
  cmd = { "UndotreeToggle", "UndotreeFocus" },
  config = function()
    vim.keymap.set("n", "<leader>u", function()
      vim.cmd.UndotreeToggle()
      vim.cmd.UndotreeFocus()
    end, { desc = "Toggle Undotree" })
  end,
}
