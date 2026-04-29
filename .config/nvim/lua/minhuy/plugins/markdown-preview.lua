return {
  "selimacerbas/markdown-preview.nvim",
  dependencies = { "selimacerbas/live-server.nvim" },
  ft = { "markdown" },
  cmd = {
    "MarkdownPreview",
    "MarkdownPreviewRefresh",
    "MarkdownPreviewStop",
    "MarkdownPreviewToggle",
  },
  config = function()
    require("markdown_preview").setup({})
  end,
}
