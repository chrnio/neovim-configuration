return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer/selection",
    },
    {
      "<leader>uf",
      function()
        vim.g.autoformat = not vim.g.autoformat
        vim.notify("Format on save: " .. (vim.g.autoformat and "on (all filetypes)" or "off (per-filetype list only)"))
      end,
      desc = "Toggle format on save",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      rust = { "rustfmt" },
      go = { "goimports", "gofmt", stop_after_first = true },
      c = { "clang_format" },
      cpp = { "clang_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 3000,
    },
    formatters = {
      shfmt = { prepend_args = { "-i", "2", "-ci" } },
    },

    format_on_save = function(bufnr)
      if vim.b[bufnr].autoformat == false then
        return nil
      end
      local ft = vim.bo[bufnr].filetype
      if vim.g.autoformat or (vim.g.autoformat_filetypes or {})[ft] then
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end
      return nil
    end,
    notify_on_error = true,
    notify_no_formatters = false,
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.api.nvim_create_user_command("FormatToggle", function(args)
      if args.bang then
        vim.b.autoformat = vim.b.autoformat == false and nil or false
        vim.notify("Format on save for this buffer: " .. (vim.b.autoformat == false and "off" or "default"))
      else
        vim.g.autoformat = not vim.g.autoformat
        vim.notify("Format on save: " .. (vim.g.autoformat and "on" or "off"))
      end
    end, { bang = true, desc = "Toggle format on save (! for current buffer only)" })
  end,
}
