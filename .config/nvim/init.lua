-- Neovim init.lua configuration

-- Basic settings
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.ignorecase = true          -- Ignore case in search
vim.opt.smartcase = true           -- Override ignorecase if search contains uppercase
vim.opt.hlsearch = false           -- Don't highlight search results
vim.opt.incsearch = true           -- Incremental search
vim.opt.wrap = false               -- Don't wrap lines
vim.opt.tabstop = 4                -- Number of spaces tabs count for
vim.opt.shiftwidth = 4             -- Size of an indent
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.autoindent = true          -- Copy indent from current line
vim.opt.smartindent = true         -- Smart autoindenting
vim.opt.termguicolors = true       -- True color support
vim.opt.scrolloff = 8              -- Minimum lines to keep above/below cursor
vim.opt.signcolumn = 'yes'         -- Always show sign column
vim.opt.updatetime = 300           -- Faster completion
vim.opt.timeoutlen = 500           -- Time to wait for mapped sequence
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard
vim.opt.splitright = true          -- Split vertical windows to the right
vim.opt.splitbelow = true          -- Split horizontal windows below
vim.opt.swapfile = false           -- Don't use swapfile
vim.opt.backup = false             -- Don't create backup files
vim.opt.undofile = true            -- Enable persistent undo
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')

-- Create undo directory if it doesn't exist
vim.fn.mkdir(vim.fn.expand('~/.config/nvim/undo'), 'p')

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Resize windows with arrows
keymap('n', '<C-Up>', ':resize -2<CR>', opts)
keymap('n', '<C-Down>', ':resize +2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Navigate buffers
keymap('n', '<S-l>', ':bnext<CR>', opts)
keymap('n', '<S-h>', ':bprevious<CR>', opts)

-- Clear search highlighting with Esc
keymap('n', '<Esc>', ':noh<CR>', opts)

-- Save file
keymap('n', '<leader>w', ':w<CR>', opts)

-- Quit
keymap('n', '<leader>q', ':q<CR>', opts)

-- Visual mode: Stay in indent mode
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Move text up and down
keymap('v', 'J', ":m '>+1<CR>gv=gv", opts)
keymap('v', 'K', ":m '<-2<CR>gv=gv", opts)

-- File explorer
keymap('n', '<leader>e', ':Explore<CR>', opts)

-- Colorscheme (using built-in one)
vim.cmd('colorscheme desert')

-- Status line
vim.opt.laststatus = 2
vim.opt.showmode = false

-- Simple status line
vim.opt.statusline = '%f %h%w%m%r %=%(%l,%c%V %= %P%)'

-- Auto commands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group = 'TrimWhitespace',
  pattern = '*',
  command = [[%s/\s\+$//e]],
})
