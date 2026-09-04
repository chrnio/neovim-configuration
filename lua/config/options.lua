vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.g.autoformat = false
vim.g.autoformat_filetypes = { rust = true, go = true, lua = true }

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 6
opt.sidescrolloff = 8

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.splitright = true
opt.splitbelow = true

opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true

opt.termguicolors = true
opt.wrap = false
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "  ", trail = "-", nbsp = "+" }
opt.showmode = false
opt.pumheight = 12
opt.winborder = "rounded"

opt.foldlevel = 99
opt.foldlevelstart = 99

opt.clipboard = "unnamedplus"

opt.completeopt = { "menu", "menuone", "noselect" }

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

vim.g.mason_auto_install = true
