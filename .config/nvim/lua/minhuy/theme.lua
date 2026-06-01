local M = {}

M.palette = {
  bg = "#1a1a1a",
  bg_alt = "#2e2e2e",
  selection = "#4d4d4d",
  border = "#6b6b6b",
  comment = "#888888",
  fg = "#d4d4d4",
  fg_alt = "#aaaaaa",
  white = "#d4d4d4",
  red = "#b56d6d",
  red_bright = "#b56d6d",
  green = "#7a9c7a",
  green_bright = "#7a9c7a",
  yellow = "#b5ad6d",
  yellow_bright = "#b5ad6d",
  blue = "#6d8bb5",
  blue_bright = "#6d8bb5",
  magenta = "#906db5",
  magenta_bright = "#906db5",
  cyan = "#6d9cb5",
  cyan_bright = "#6d9cb5",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.apply()
  local p = M.palette

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.g.colors_name = "monochrome-wave"

  hl("Normal", { fg = p.fg, bg = p.bg })
  hl("NormalNC", { fg = p.fg_alt, bg = p.bg })
  hl("NormalFloat", { fg = p.fg, bg = p.bg_alt })
  hl("FloatBorder", { fg = p.border, bg = p.bg_alt })
  hl("FloatTitle", { fg = p.yellow, bg = p.bg_alt, bold = true })
  hl("Cursor", { fg = p.bg, bg = p.white })
  hl("CursorLine", { bg = p.bg_alt })
  hl("CursorLineNr", { fg = p.yellow_bright, bold = true })
  hl("LineNr", { fg = p.comment })
  hl("SignColumn", { fg = p.comment, bg = p.bg })
  hl("ColorColumn", { bg = p.bg_alt })
  hl("Visual", { fg = p.white, bg = p.selection })
  hl("Search", { fg = p.bg, bg = p.yellow })
  hl("IncSearch", { fg = p.bg, bg = p.cyan_bright })
  hl("CurSearch", { fg = p.bg, bg = p.yellow_bright })
  hl("MatchParen", { fg = p.yellow_bright, bg = p.selection, bold = true })
  hl("Pmenu", { fg = p.fg, bg = p.bg_alt })
  hl("PmenuSel", { fg = p.bg, bg = p.blue_bright })
  hl("PmenuSbar", { bg = p.selection })
  hl("PmenuThumb", { bg = p.border })
  hl("StatusLine", { fg = p.fg, bg = p.bg_alt })
  hl("StatusLineNC", { fg = p.comment, bg = p.bg_alt })
  hl("WinSeparator", { fg = p.border })
  hl("TabLine", { fg = p.fg_alt, bg = p.bg_alt })
  hl("TabLineSel", { fg = p.bg, bg = p.comment, bold = true })
  hl("TabLineFill", { bg = p.bg })
  hl("Folded", { fg = p.comment, bg = p.bg_alt })
  hl("FoldColumn", { fg = p.comment, bg = p.bg })
  hl("NonText", { fg = p.selection })
  hl("Whitespace", { fg = p.selection })
  hl("SpecialKey", { fg = p.comment })
  hl("Directory", { fg = p.blue_bright })

  hl("Comment", { fg = p.comment, italic = true })
  hl("Constant", { fg = p.cyan_bright })
  hl("String", { fg = p.green_bright })
  hl("Character", { fg = p.green_bright })
  hl("Number", { fg = p.yellow })
  hl("Boolean", { fg = p.yellow })
  hl("Float", { fg = p.yellow })
  hl("Identifier", { fg = p.fg })
  hl("Function", { fg = p.blue_bright })
  hl("Statement", { fg = p.magenta_bright })
  hl("Conditional", { fg = p.magenta_bright })
  hl("Repeat", { fg = p.magenta_bright })
  hl("Label", { fg = p.magenta })
  hl("Operator", { fg = p.fg_alt })
  hl("Keyword", { fg = p.magenta_bright })
  hl("Exception", { fg = p.red_bright })
  hl("PreProc", { fg = p.cyan })
  hl("Include", { fg = p.cyan_bright })
  hl("Define", { fg = p.cyan_bright })
  hl("Macro", { fg = p.cyan_bright })
  hl("PreCondit", { fg = p.cyan_bright })
  hl("Type", { fg = p.yellow_bright })
  hl("StorageClass", { fg = p.yellow_bright })
  hl("Structure", { fg = p.yellow_bright })
  hl("Typedef", { fg = p.yellow_bright })
  hl("Special", { fg = p.cyan_bright })
  hl("SpecialChar", { fg = p.cyan_bright })
  hl("Tag", { fg = p.blue })
  hl("Delimiter", { fg = p.fg_alt })
  hl("Debug", { fg = p.red_bright })
  hl("Underlined", { fg = p.blue_bright, underline = true })
  hl("Error", { fg = p.red_bright })
  hl("Todo", { fg = p.bg, bg = p.yellow_bright, bold = true })

  hl("DiagnosticError", { fg = p.red_bright })
  hl("DiagnosticWarn", { fg = p.yellow })
  hl("DiagnosticInfo", { fg = p.blue_bright })
  hl("DiagnosticHint", { fg = p.cyan_bright })
  hl("DiagnosticOk", { fg = p.green_bright })
  hl("DiagnosticUnderlineError", { sp = p.red_bright, undercurl = true })
  hl("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
  hl("DiagnosticUnderlineInfo", { sp = p.blue_bright, undercurl = true })
  hl("DiagnosticUnderlineHint", { sp = p.cyan_bright, undercurl = true })

  hl("DiffAdd", { fg = p.green_bright, bg = p.bg_alt })
  hl("DiffChange", { fg = p.yellow, bg = p.bg_alt })
  hl("DiffDelete", { fg = p.red_bright, bg = p.bg_alt })
  hl("DiffText", { fg = p.blue_bright, bg = p.selection })
  hl("Added", { fg = p.green_bright })
  hl("Changed", { fg = p.yellow })
  hl("Removed", { fg = p.red_bright })

  hl("GitSignsAdd", { fg = p.green_bright })
  hl("GitSignsChange", { fg = p.yellow })
  hl("GitSignsDelete", { fg = p.red_bright })

  hl("TelescopeNormal", { fg = p.fg, bg = p.bg_alt })
  hl("TelescopeBorder", { fg = p.border, bg = p.bg_alt })
  hl("TelescopeSelection", { fg = p.white, bg = p.selection })
  hl("TelescopeMatching", { fg = p.yellow_bright, bold = true })
  hl("TelescopePromptPrefix", { fg = p.cyan_bright })
  hl("TelescopePromptTitle", { fg = p.bg, bg = p.cyan })
  hl("TelescopeResultsTitle", { fg = p.bg, bg = p.blue })
  hl("TelescopePreviewTitle", { fg = p.bg, bg = p.green })

  hl("NeoTreeNormal", { fg = p.fg, bg = p.bg })
  hl("NeoTreeNormalNC", { fg = p.fg_alt, bg = p.bg })
  hl("NeoTreeDirectoryName", { fg = p.blue_bright })
  hl("NeoTreeDirectoryIcon", { fg = p.blue })
  hl("NeoTreeFileName", { fg = p.fg })
  hl("NeoTreeFileIcon", { fg = p.fg_alt })
  hl("NeoTreeModified", { fg = p.yellow })
  hl("NeoTreeGitAdded", { fg = p.green_bright })
  hl("NeoTreeGitDeleted", { fg = p.red_bright })
  hl("NeoTreeGitModified", { fg = p.yellow })
  hl("NeoTreeIndentMarker", { fg = p.selection })
  hl("NeoTreeExpander", { fg = p.comment })

  hl("CmpItemAbbr", { fg = p.fg })
  hl("CmpItemAbbrDeprecated", { fg = p.comment, strikethrough = true })
  hl("CmpItemAbbrMatch", { fg = p.blue_bright, bold = true })
  hl("CmpItemAbbrMatchFuzzy", { fg = p.cyan_bright, bold = true })
  hl("CmpItemKind", { fg = p.magenta_bright })
  hl("CmpItemMenu", { fg = p.comment })

  hl("@comment", { link = "Comment" })
  hl("@keyword", { link = "Keyword" })
  hl("@keyword.function", { link = "Keyword" })
  hl("@string", { link = "String" })
  hl("@number", { link = "Number" })
  hl("@boolean", { link = "Boolean" })
  hl("@function", { link = "Function" })
  hl("@function.call", { link = "Function" })
  hl("@method", { link = "Function" })
  hl("@variable", { fg = p.fg })
  hl("@variable.builtin", { fg = p.red })
  hl("@constant", { link = "Constant" })
  hl("@type", { link = "Type" })
  hl("@property", { fg = p.fg_alt })
  hl("@punctuation", { fg = p.fg_alt })
  hl("@operator", { link = "Operator" })
end

function M.lualine_theme()
  local p = M.palette

  return {
    normal = {
      a = { fg = p.bg, bg = p.blue_bright, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_alt },
      c = { fg = p.fg_alt, bg = p.bg },
    },
    insert = {
      a = { fg = p.bg, bg = p.green_bright, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_alt },
      c = { fg = p.fg_alt, bg = p.bg },
    },
    visual = {
      a = { fg = p.bg, bg = p.magenta_bright, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_alt },
      c = { fg = p.fg_alt, bg = p.bg },
    },
    replace = {
      a = { fg = p.bg, bg = p.red_bright, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_alt },
      c = { fg = p.fg_alt, bg = p.bg },
    },
    command = {
      a = { fg = p.bg, bg = p.yellow_bright, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_alt },
      c = { fg = p.fg_alt, bg = p.bg },
    },
    inactive = {
      a = { fg = p.comment, bg = p.bg_alt, gui = "bold" },
      b = { fg = p.comment, bg = p.bg_alt },
      c = { fg = p.comment, bg = p.bg },
    },
  }
end

return M
