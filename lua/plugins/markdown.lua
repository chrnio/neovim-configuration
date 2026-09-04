return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  cmd = { "RenderMarkdown" },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown rendering", ft = "markdown" },
  },
  opts = {
    render_modes = { "n", "c" },
    heading = { icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " } },
    code = { style = "normal" },
    checkbox = { enabled = false },
    completions = { lsp = { enabled = true } },
  },
}
