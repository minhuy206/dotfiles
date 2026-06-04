return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonUpdate" },
  event = "VeryLazy",
  config = function()
    require("mason").setup({})

    local ok, registry = pcall(require, "mason-registry")
    if not ok then return end

    local packages = { "verible", "texlab" }

    local function ensure_packages()
      for _, name in ipairs(packages) do
        if registry.has_package(name) then
          local pkg = registry.get_package(name)
          if not pkg:is_installed() then
            pkg:install()
          end
        end
      end
    end

    if registry.refresh then
      registry.refresh(ensure_packages)
    else
      ensure_packages()
    end
  end,
}
