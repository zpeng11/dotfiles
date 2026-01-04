vim.g.mapleader = " "

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

vim.keymap.set("i", "wv", "<Esc>")
vim.keymap.set("v", "wv", "<Esc>")

-- map("n", "<leader>w", ":update<CR>", { desc = "Save file" })
-- map("n", "<leader>q", ":quit<CR>", { desc = "Quit" })
-- map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
-- map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlight" })

-- map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
-- map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
-- map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
-- map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
-- map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
-- map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
-- map("n", "<leader>sx", ":close<CR>", { desc = "Close split" })

-- map("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
-- map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
-- map("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
-- map("n", "<leader>tp", ":tabp<CR>", { desc = "Previous tab" })
