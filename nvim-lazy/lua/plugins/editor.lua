return {
  {
    "nvim-mini/mini.hipatterns",
    event = "BufReadPre",
    opts = function()
      local hipatterns = require("mini.hipatterns")
      return {
        highlighters = {
          -- highlight #rrggbb hex colors
          hex_color = hipatterns.gen_highlighter.hex_color({
            group = "MiniHipatternsHexColor",
            bg = true,
          }),
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    -- prompt position
    opts = {
      defaults = {
        layout_config = {
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
      },
    },
  },
  -- adding telescope file browser
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-file-browser.nvim" },
    opts = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope._extensions.file_browser.actions")

      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          --disable netrw and use telescope file browser
          hijack_netrw = true,
          mappings = {
            ["n"] = {
              ["N"] = fb_actions.create,
              ["r"] = fb_actions.rename,
              ["d"] = fb_actions.remove,
              ["y"] = fb_actions.copy,
              ["m"] = fb_actions.move,
              ["u"] = fb_actions.goto_parent_dir,
            },
          },
        },
      }
    end,
  },
}
