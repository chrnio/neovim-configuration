local parsers = {
  "bash", "c", "cpp", "css", "diff", "dockerfile", "git_config", "gitcommit",
  "gitignore", "go", "gomod", "gosum", "gowork", "html", "java", "javascript",
  "jsdoc", "json", "lua", "luadoc", "make", "markdown",
  "markdown_inline", "query", "regex", "rust", "toml", "tsx", "typescript",
  "vim", "vimdoc", "yaml",
}

local ts_indent = {
  lua = true, rust = true, go = true, javascript = true, javascriptreact = true,
  typescript = true, typescriptreact = true, json = true, jsonc = true, yaml = true,
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()

      if vim.fn.executable("tree-sitter") == 1 then
        pcall(require("nvim-treesitter").install, parsers)
      else
        vim.schedule(function()
          vim.notify("nvim-treesitter: `tree-sitter` CLI not found; parsers will not be installed (pacman -S tree-sitter-cli)", vim.log.levels.WARN)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          local ft = ev.match
          local lang = vim.treesitter.language.get_lang(ft) or ft

          if not vim.treesitter.language.add(lang) then
            return
          end
          pcall(vim.treesitter.start, ev.buf, lang)
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          if ts_indent[ft] then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local function sel(lhs, query, desc)
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = desc })
      end
      sel("af", "@function.outer", "a function")
      sel("if", "@function.inner", "inner function")
      sel("ac", "@class.outer", "a class")
      sel("ic", "@class.inner", "inner class")
      sel("aa", "@parameter.outer", "an argument")
      sel("ia", "@parameter.inner", "inner argument")

      local function mv(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          move[fn](query, "textobjects")
        end, { desc = desc })
      end

      mv("]f", "goto_next_start", "@function.outer", "Next function")
      mv("[f", "goto_previous_start", "@function.outer", "Previous function")
    end,
  },
}
