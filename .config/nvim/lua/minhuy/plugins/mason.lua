return {
  "williamboman/mason.nvim",
  lazy = false,
  config = function()
    require("mason").setup({})

    local ok, registry = pcall(require, "mason-registry")
    if not ok then
      return
    end

    local function ensure_verible()
      if not registry.has_package("verible") then
        return
      end

      local pkg = registry.get_package("verible")
      if not pkg:is_installed() then
        pkg:install()
      end
    end

    if registry.refresh then
      registry.refresh(ensure_verible)
    else
      ensure_verible()
    end
  end,
}
