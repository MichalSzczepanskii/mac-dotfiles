local lspconfig = require("lspconfig")

return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        angularls = {
          root_diir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("angular.json", "nx.json")(fname)
          end,
          filetypes = { "typescript", "html", "htmlangular" },
        },
      },
      setup = {
        angularls = function(_, opts)
          opts.root_dir = lspconfig.util.root_pattern("angular.json", "nx.json")
        end,
      },
    },
  },
}
