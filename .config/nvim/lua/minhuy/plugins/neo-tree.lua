return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
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
    })

    local function count_real_file_buffers()
      local n = 0
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.fn.buflisted(buf) == 1 then
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
          local name = vim.api.nvim_buf_get_name(buf)
          local modified = vim.api.nvim_get_option_value("modified", { buf = buf })
          local is_empty_scratch = name == "" and not modified

          if buftype == "" and filetype ~= "neo-tree" and not is_empty_scratch then
            n = n + 1
          end
        end
      end
      return n
    end

    local function focus_neotree_when_no_file_buffer()
      if count_real_file_buffers() > 0 then
        return
      end

      local ok, neotree_cmd = pcall(require, "neo-tree.command")
      if not ok then
        pcall(vim.cmd, "Neotree focus")
        return
      end

      neotree_cmd.execute({ action = "show", source = "filesystem", position = "left" })
      neotree_cmd.execute({ action = "focus", source = "filesystem" })
    end

    local group = vim.api.nvim_create_augroup("MinhuyNeoTreeLastBufferFocus", { clear = true })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufEnter" }, {
      group = group,
      callback = function()
        vim.schedule(function()
          focus_neotree_when_no_file_buffer()
        end)
      end,
    })

    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, desc = "Toggle Neo-tree" })
    vim.keymap.set("n", "<leader>E", ":Neotree reveal<CR>", { noremap = true, silent = true, desc = "Reveal in Neo-tree" })
  end,
}
