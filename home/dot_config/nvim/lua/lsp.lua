vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- local lspconfig = require("lspconfig")

-- lspconfig.lua_ls.setup({})
-- lspconfig.pyright.setup({})
-- lspconfig.ts_ls.setup({})
-- lspconfig.gopls.setup({})
-- lspconfig.rust_analyzer.setup({})

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(event)
--     local opts = { buffer = event.buf }
--     vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
--     vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
--     vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
--     vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
--     vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
--     vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
--   end,
-- })
