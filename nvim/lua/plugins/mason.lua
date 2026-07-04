return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "emmet-ls",
        -- "djlint",
        -- "twiggy-language-server",
        -- "prettier",
        -- "pint", -- omitted in the dev-container: pint needs a PHP runtime (editor-only base)
        -- "laravel-ls",
        "intelephense",
      },
    },
  },
}
