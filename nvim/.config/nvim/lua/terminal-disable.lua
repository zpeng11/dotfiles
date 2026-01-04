vim.api.nvim_create_user_command("terminal", function()
  vim.notify("Terminal mode is disabled", vim.log.levels.ERROR)
end, { nargs = "*" })

vim.api.nvim_create_user_command("term", function()
  vim.notify("Terminal mode is disabled", vim.log.levels.ERROR)
end, { nargs = "*" })

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.notify("Terminal mode is disabled", vim.log.levels.ERROR)
    vim.cmd("bwipeout!")
  end,
})

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "term://*",
  callback = function()
    vim.notify("Terminal mode is disabled", vim.log.levels.ERROR)
    vim.cmd("bwipeout")
  end,
})
