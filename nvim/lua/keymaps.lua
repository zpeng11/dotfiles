vim.g.mapleader = " "

vim.keymap.set("i", "<leader>jk", "<Esc>", { noremap=true, silent=true })
vim.keymap.set("v", "<leader>jk", "<Esc>", { noremap=true, silent=true })

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { silent=true })
vim.keymap.set({ "n", "i" }, "<C-s>", "<Esc>:w<CR>", { silent=true })
vim.keymap.set({ "n", "v" }, "<leader>hh", "^")
vim.keymap.set("i", "<leader>hh", "<C-o>^")
vim.keymap.set({ "n", "v" }, "<leader>ll", "$")
vim.keymap.set("i", "<leader>ll", "<C-o>$")

vim.keymap.set("i", "<leader>zz", "<C-o>zz")
vim.keymap.set("i", "<leader>zt", "<C-o>zt")
vim.keymap.set("i", "<leader>zb", "<C-o>zb")

vim.keymap.set("n", "<leader>jj", "<C-d>")
vim.keymap.set("i", "<leader>jj", "<C-o><C-d>")
vim.keymap.set("n", "<leader>kk", "<C-u>")
vim.keymap.set("i", "<leader>kk", "<C-o><C-u>")

local undo_breakpoints = { ",", ".", ";", ":", "!", "?", ")", "]", "}", " " }

for _, ch in ipairs(undo_breakpoints) do
  vim.keymap.set("i", ch, ch .. "<C-g>u", { noremap = true, silent = true })
end

vim.keymap.set("i", "<CR>", "<CR><C-g>u", { noremap = true, silent = true })

vim.keymap.set("i", "<C-v>", "<C-r>+", { noremap=true, silent=true })

vim.keymap.set("n", "U", "<C-r>", { noremap = true, silent = true })
