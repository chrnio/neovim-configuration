local default = "tokyonight-night"
local state_file = vim.fn.stdpath("state") .. "/colorscheme"

-- groups whose background is cleared so the terminal shows through
local transparent_groups = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"FloatTitle",
	"SignColumn",
	"LineNr",
	"CursorLineNr",
	"EndOfBuffer",
	"NonText",
	"FoldColumn",
	"Folded",
	"VertSplit",
	"WinSeparator",
	"MsgArea",
	"MsgSeparator",
	"StatusLine",
	"StatusLineNC",
	"TabLine",
	"TabLineFill",
	"TabLineSel",
	"WinBar",
	"WinBarNC",
	"TelescopeNormal",
	"TelescopeBorder",
	"TelescopeTitle",
	"TelescopePromptNormal",
	"TelescopePromptBorder",
	"TelescopeResultsNormal",
	"TelescopeResultsBorder",
	"TelescopePreviewNormal",
	"TelescopePreviewBorder",
}

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

local function strip_backgrounds()
	if not vim.g.user_transparent then
		return
	end
	for _, group in ipairs(transparent_groups) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
		if ok then
			hl.bg = "NONE"
			hl.ctermbg = "NONE"
			pcall(vim.api.nvim_set_hl, 0, group, hl)
		end
	end
end

local function setup_colorscheme()
	vim.o.background = "dark"
	if vim.g.user_transparent == nil then
		vim.g.user_transparent = true
	end

	local group = vim.api.nvim_create_augroup("user_colorscheme", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function(ev)
			strip_italics()
			strip_backgrounds()
			local f = io.open(state_file, "w")
			if f then
				f:write(ev.match, "\n")
				f:close()
			end
		end,
	})

	vim.keymap.set("n", "<leader>ub", function()
		vim.g.user_transparent = not vim.g.user_transparent
		pcall(vim.cmd.colorscheme, vim.g.colors_name or default)
	end, { desc = "Toggle transparent background" })

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
		dependencies = {
			"catppuccin/nvim",
			"navarasu/onedark.nvim",
			"bluz71/vim-moonfly-colors",
			"oskarnurm/koda.nvim",
			"sainnhe/gruvbox-material",
			"Shatur/neovim-ayu",
			"eldritch-theme/eldritch.nvim",
			"neanias/everforest-nvim",
			"ellisonleao/gruvbox.nvim",
			"miikanissi/modus-themes.nvim",
		},
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

	-- gruvbox-material, dark + medium contrast  ->  :colorscheme gruvbox-material
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_foreground = "material"
			vim.g.gruvbox_material_better_performance = 1
			vim.g.gruvbox_material_enable_italic = 0
			vim.g.gruvbox_material_disable_italic_comment = 1
		end,
	},

	-- ayu  ->  :colorscheme ayu-dark
	{
		"Shatur/neovim-ayu",
		lazy = false,
		priority = 1000,
		config = function()
			require("ayu").setup({ mirage = false })
		end,
	},

	-- eldritch  ->  :colorscheme eldritch
	{
		"eldritch-theme/eldritch.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			styles = {
				comments = { italic = false },
				keywords = { italic = false },
				functions = {},
				variables = {},
			},
		},
	},

	-- everforest, hard contrast  ->  :colorscheme everforest
	{
		"neanias/everforest-nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("everforest").setup({
				background = "hard",
				italics = false,
				disable_italic_comments = true,
			})
		end,
	},

	-- gruvbox (ellisonleo), medium contrast  ->  :colorscheme gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			contrast = "",
			italic = {
				strings = false,
				emphasis = false,
				comments = false,
				operators = false,
				folds = false,
			},
		},
	},

	-- modus  ->  :colorscheme modus_vivendi
	{
		"miikanissi/modus-themes.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("modus-themes").setup({
				style = "modus_vivendi",
				variants = { modus_vivendi = "default" },
				styles = {
					comments = { italic = false },
					keywords = { italic = false },
					functions = {},
					variables = {},
				},
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		keys = {
			{ "<leader>ut", "<cmd>Telescope colorscheme enable_preview=true<CR>", desc = "Pick colorscheme" },
		},
	},
}
