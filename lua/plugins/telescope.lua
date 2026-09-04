local root_markers = {
  ".git", "pom.xml", "mvnw", "build.gradle", "build.gradle.kts", "gradlew",
  "Cargo.toml", "go.mod", "package.json", "CMakeLists.txt", "compile_commands.json",
}

local function root()
  return vim.fs.root(0, root_markers) or vim.uv.cwd()
end

return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",

    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files({ cwd = root() }) end, desc = "Find files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep({ cwd = root() }) end, desc = "Live grep" },
    { "<leader>fw", function() require("telescope.builtin").grep_string({ cwd = root() }) end, desc = "Grep word under cursor" },
    { "<leader>fw", function() require("telescope.builtin").grep_string({ cwd = root() }) end, mode = "v", desc = "Grep selection" },
    { "<leader>fb", "<cmd>Telescope buffers sort_mru=true<CR>", desc = "Buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
    { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace symbols" },
    { "<leader>xx", "<cmd>Telescope diagnostics bufnr=0<CR>", desc = "Buffer diagnostics" },
    { "<leader>xX", "<cmd>Telescope diagnostics<CR>", desc = "Workspace diagnostics" },
    { "<leader>fR", "<cmd>Telescope resume<CR>", desc = "Resume last picker" },
  },
  opts = function()
    local actions = require("telescope.actions")
    return {
      defaults = {
        path_display = { "filename_first" },
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top", horizontal = { preview_width = 0.55 } },
        file_ignore_patterns = { "^%.git/", "node_modules/", "^target/", "^build/", "^dist/", "^%.gradle/" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<Esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = { hidden = true },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    pcall(telescope.load_extension, "fzf")
  end,
}
