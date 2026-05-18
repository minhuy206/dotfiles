return {
  "selimacerbas/markdown-preview.nvim",
  main = "markdown_preview",
  dependencies = { "selimacerbas/live-server.nvim" },
  ft = { "markdown" },
  cmd = {
    "MarkdownPreview",
    "MarkdownPreviewRefresh",
    "MarkdownPreviewStop",
    "MarkdownPreviewToggle",
  },
  opts = {},
}
