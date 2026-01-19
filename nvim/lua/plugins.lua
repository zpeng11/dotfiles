local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  print("Done.")
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        -- 这里的配置可以控制标注的样式
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,  -- 开启侧边栏符号
        numhl      = true, -- 开启行号高亮 (可选)
        linehl     = false, -- 开启整行高亮 (可选，开启后非常明显)
        word_diff  = false, -- 开启行内具体修改单词的高亮 (可选)
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = true, -- 开启行末 Git Blame 信息 (非常推荐)
        on_attach = function(bufnr)
          local gs = require('gitsigns')

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map('n', '<leader>hn', gs.next_hunk, 'Next hunk')
          map('n', '<leader>hp', gs.prev_hunk, 'Prev hunk')

          -- Actions
          -- map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
          -- map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
          -- map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
          -- map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
          --
          -- -- View
          -- map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
          -- map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
          -- map('n', '<leader>hd', gs.diffthis, 'Diff this')
          --
          -- -- Text object (select hunk)
          -- map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
        end
      })
    end
  },
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  }
})
