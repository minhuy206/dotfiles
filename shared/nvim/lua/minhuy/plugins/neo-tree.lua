local function focus_file_window()
  local current_win = vim.api.nvim_get_current_win()
  local previous_win = vim.fn.win_getid(vim.fn.winnr("#"))

  if previous_win ~= 0 and vim.api.nvim_win_is_valid(previous_win) then
    local previous_buf = vim.api.nvim_win_get_buf(previous_win)
    if vim.bo[previous_buf].filetype ~= "neo-tree" then
      vim.api.nvim_set_current_win(previous_win)
      return
    end
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local is_normal_window = vim.api.nvim_win_get_config(win).relative == ""

    if win ~= current_win and is_normal_window and vim.bo[buf].filetype ~= "neo-tree" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

local function toggle_neotree_focus()
  if vim.bo.filetype == "neo-tree" then
    focus_file_window()
    return
  end

  require("neo-tree.command").execute({
    action = "focus",
    source = "filesystem",
    position = "left",
  })
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  init = function()
    local group = vim.api.nvim_create_augroup("MinhuyNeoTreeStartup", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      once = true,
      callback = function()
        if vim.fn.argc() == 0 then
          vim.cmd("Neotree source=filesystem position=current")
        end
      end,
    })
  end,
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>",  noremap = true, silent = true, desc = "Toggle Neo-tree" },
    { "<leader>E", "<cmd>Neotree reveal<CR>",  noremap = true, silent = true, desc = "Reveal in Neo-tree" },
    { "<leader>o", toggle_neotree_focus,        noremap = true, silent = true, desc = "Toggle Neo-tree focus" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    close_if_last_window = false,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_modified_markers = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
        highlight = "NeoTreeIndentMarker",
        with_expanders = nil,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "󰜌",
        default = "*",
        highlight = "NeoTreeFileIcon",
      },
      modified = {
        symbol = "[+]",
        highlight = "NeoTreeModified",
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
        highlight = "NeoTreeFileName",
      },
      git_status = {
        symbols = {
          added = "✚",
          deleted = "✖",
          modified = "",
          renamed = "󰁕",
          untracked = "?",
          ignored = "◌",
          unstaged = "󰄱",
          staged = "",
          conflict = "",
        },
      },
    },
    window = {
      position = "left",
      width = 25,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ["<space>"] = "none",
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["<esc>"] = "cancel",
        ["P"] = { "toggle_preview", config = { use_float = true } },
        ["l"] = "focus_preview",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["t"] = "open_tabnew",
        ["w"] = "open_with_window_picker",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["Z"] = "expand_all_nodes",
        ["a"] = { "add", config = { show_path = "relative" } },
        ["A"] = "add_directory",
        ["d"] = "delete",
        ["r"] = "rename",
        ["c"] = "copy",
        ["m"] = "move",
        ["q"] = "close_window",
        ["R"] = "refresh",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
        ["i"] = "show_file_details",
      },
    },
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      use_libuv_file_watcher = true,
    },
  },
}
