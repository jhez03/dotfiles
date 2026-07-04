-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Autocmds are automatically loaded on the VeryLazy event
-- Add any additional autocmds here

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "twig" },
--   callback = function()
--     -- Treesitter indent tends to behave better for mixed template languages
--     vim.bo.indentexpr = "v:lua.require'nvim-treesitter.indent'.get_indent(v:lnum)"
--     vim.bo.autoindent = true
--     vim.bo.smartindent = false
--   end,
-- })
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = "*.twig",
--   callback = function()
--     vim.bo.filetype = "twig.html"
--   end,
-- })
vim.filetype.add({
  pattern = {
    [".*%.blade%.php"] = "blade",
  },
})
