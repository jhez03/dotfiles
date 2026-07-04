return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
      ---@type lspconfig.options
      servers = {
        html = {
          filetypes = { "html", "twig", "html.twig" },
        },
        emmet_ls = {
          filetypes = { "html", "twig", "html.twig" },
        },
        intelephense = {
          settings = {
            intelephense = {
              licenceKey = vim.fn.readfile(vim.fn.expand("~/.config/intelephense/license.txt"))[1],
              inlayHints = { enable = false },
            },
          },
        },
      },
    },
  },
}
