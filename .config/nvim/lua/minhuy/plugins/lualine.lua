return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local function current_os()
      local sysname = (vim.uv or vim.loop).os_uname().sysname

      if sysname == "Darwin" then
        return ""
      end

      if sysname == "Linux" then
        return ""
      end

      if sysname == "Windows_NT" then
        return ""
      end

      return sysname
    end

    require("lualine").setup({
      options = {
        theme = "modus-vivendi",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", current_os, "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
