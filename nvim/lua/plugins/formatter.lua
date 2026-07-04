return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- twig = { "djlint" },
        -- yaml = { "prettier" },
        -- php/blade use pint, which needs a PHP runtime not present in the editor-only
        -- dev-container base. Re-add `php = { "pint" }` / `blade = { "pint" }` if you add PHP.
        -- vue = { "prettier" },
      },
    },
  },
}
