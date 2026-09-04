local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shorter window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider window" })

map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Delete other buffers" })

map("v", "<", "<gv")
map("v", ">", ">gv")

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

map({ "n", "i", "x" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

map("n", "<leader>tt", function()
  vim.cmd("botright 15split | terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal (split)" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })

map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })
map("n", "<leader>us", function()
  vim.wo.spell = not vim.wo.spell
end, { desc = "Toggle spell" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
end, { desc = "Toggle inlay hints" })
