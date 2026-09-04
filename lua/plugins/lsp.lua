local mason_packages = {
  "jdtls",
  "lua-language-server",
  "typescript-language-server",
  "eslint-lsp",
  "html-lsp",
  "css-lsp",
  "json-lsp",
  "yaml-language-server",
  "bash-language-server",

  "stylua",
  "prettier",
  "shfmt",

  "codelldb",
  "js-debug-adapter",
  "java-debug-adapter",
  "java-test",
}

local servers = {
  "lua_ls", "ts_ls", "eslint", "html", "cssls", "jsonls", "yamlls", "bashls",
  "clangd", "rust_analyzer", "gopls",
}

return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
    config = function(_, opts)
      require("mason").setup(opts)

      local registry = require("mason-registry")
      local function install_missing()
        local missing = {}
        for _, name in ipairs(mason_packages) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            missing[#missing + 1] = name
            pkg:install()
          end
        end
        if #missing > 0 then
          vim.notify("Mason: installing " .. table.concat(missing, ", ") .. " (see :Mason)", vim.log.levels.INFO)
        end
      end
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        registry.refresh(install_missing)
      end, { desc = "Install every Mason package this config expects" })
      if vim.g.mason_auto_install ~= false then
        registry.refresh(install_missing)
      end
    end,
  },

  { "b0o/SchemaStore.nvim", lazy = true },

  { "mfussenegger/nvim-jdtls", ft = "java" },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "b0o/SchemaStore.nvim" },
    config = function()

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2, source = "if_many" },
        float = { source = "if_many" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          local tb = function(picker)
            return function()
              require("telescope.builtin")[picker]({ reuse_win = true })
            end
          end

          map("n", "gd", tb("lsp_definitions"), "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "grr", tb("lsp_references"), "References")
          map("n", "gri", tb("lsp_implementations"), "Implementations")
          map("n", "grt", tb("lsp_type_definitions"), "Type definition")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cs", vim.lsp.buf.signature_help, "Signature help")
          map("n", "<leader>cR", "<cmd>LspRestart<CR>", "Restart LSP")
          map("n", "<leader>cw", function()
            vim.print(vim.lsp.buf.list_workspace_folders())
          end, "List workspace folders")

          if client:supports_method("textDocument/documentHighlight") then
            local group = vim.api.nvim_create_augroup("user_lsp_highlight_" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = group, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = group, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,

              library = { vim.env.VIMRUNTIME, "${3rd}/luv/library" },
            },
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
          },
        },
      })

      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--completion-style=detailed" },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { allFeatures = true },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = false,
            staticcheck = true,
            analyses = { unusedparams = true },
            hints = { parameterNames = true, assignVariableTypes = true },
          },
        },
      })

      vim.lsp.config("ts_ls", {
        settings = {
          typescript = { inlayHints = { includeInlayParameterNameHints = "literals", includeInlayVariableTypeHints = true } },
          javascript = { inlayHints = { includeInlayParameterNameHints = "literals", includeInlayVariableTypeHints = true } },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.enable(servers)
    end,
  },
}
