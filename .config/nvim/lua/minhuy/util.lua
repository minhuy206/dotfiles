local M = {}

function M.has_exe(name)
  return vim.fn.executable(name) == 1
end

function M.is_normal_buf(buf)
  return vim.bo[buf].buftype == ""
end

function M.ft_in(buf, set)
  local ft = vim.bo[buf or 0].filetype
  for _, v in ipairs(set) do
    if v == ft then return true end
  end
  return false
end

return M
