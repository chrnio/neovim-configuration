return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
  },

  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 300 },
      list = { selection = { preselect = true, auto_insert = false } },
      menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
    },
    signature = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    cmdline = {
      enabled = true,
      keymap = { preset = "cmdline" },
      completion = { menu = { auto_show = true } },
    },
    fuzzy = { implementation = "prefer_rust" },
  },
}
