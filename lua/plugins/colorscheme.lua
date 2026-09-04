local default = "tokyonight-night"
local state_file = vim.fn.stdpath("state") .. "/colorscheme"

local function saved()
  local f = io.open(state_file, "r")
  if not f then
    return nil
  end
  local name = vim.trim(f:read("*l") or "")
  f:close()
  return name ~= "" and name or nil
end

local function strip_italics()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.italic and not hl.link then
      hl.italic = false
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

local function setup_colorscheme()
  local group = vim.api.nvim_create_augroup("user_colorscheme", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function(ev)
      strip_italics()
      local f = io.open(state_file, "w")
      if f then
        f:write(ev.match, "\n")
        f:close()
      end
    end,
  })
  local name = saved() or default
  if not pcall(vim.cmd.colorscheme, name) then

    pcall(vim.cmd.colorscheme, default)
  end
end

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      styles = { comments = { italic = false }, keywords = { italic = false } },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      setup_colorscheme()
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
  },
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    init = function()

      vim.g.onedark_config = { style = "darker", code_style = { comments = "none", keywords = "none" } }
    end,
  },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.moonflyItalics = false
    end,
  },
  { "oskarnurm/koda.nvim", lazy = false, priority = 1000 },

  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>ut", "<cmd>Telescope colorscheme enable_preview=true<CR>", desc = "Pick colorscheme" },
    },
  },
}
