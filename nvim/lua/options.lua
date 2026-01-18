vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.mouse = "a"
if vim.env.SSH_TTY then
  vim.opt.clipboard = ""
else
  vim.opt.clipboard = "unnamedplus"
end

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.undoreload = 10000

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

vim.opt.splitbelow = true
vim.opt.splitright = true

-- 设置折叠方式为表达式
vim.opt.foldmethod = "expr"
-- 使用 Treesitter 的表达式
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 默认不折叠代码
vim.opt.foldlevel = 99

vim.opt.fillchars = {
  fold = " ",        -- 填充折叠行的字符，设为空格更干净
  foldopen = "",    -- 展开时的图标
  foldsep = " ",     -- 折叠分割符
  foldclose = "",   -- 关闭时的图标
}
