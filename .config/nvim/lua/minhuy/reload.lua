local M = {}

local reloadable_modules = {
  "minhuy.reload",
  "minhuy.set",
  "minhuy.remap",
}

function M.reload()
  local ok, err = pcall(function()
    for _, name in ipairs(reloadable_modules) do
      package.loaded[name] = nil
    end

    require("minhuy.set")
    require("minhuy.remap")

    local lazy_ok, reloader = pcall(require, "lazy.manage.reloader")
    if lazy_ok then
      reloader.check()
    end
  end)

  if ok then
    vim.notify("Neovim config reloaded")
  else
    vim.notify("Failed to reload Neovim config:\n" .. err, vim.log.levels.ERROR)
  end
end

function M.status()
  local function map_rhs(lhs, mode)
    local map = vim.fn.maparg(lhs, mode, false, true)
    if vim.tbl_isempty(map) then
      return "missing"
    end

    return map.callback and "<Lua callback>" or map.rhs
  end

  local lines = {
    "MYVIMRC: " .. tostring(vim.env.MYVIMRC),
    "config: " .. vim.fn.stdpath("config"),
    "leader: " .. vim.inspect(vim.g.mapleader),
    "minhuy.remap loaded: " .. tostring(package.loaded["minhuy.remap"] ~= nil),
    "<leader>y: " .. map_rhs("<leader>y", "n"),
    "<leader><leader>: " .. map_rhs("<leader><leader>", "n"),
  }

  vim.notify(table.concat(lines, "\n"))
end

return M
