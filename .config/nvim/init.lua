-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local lspconfig = require("lspconfig")
local mason_registry = require("mason-registry")

local angularls_path = mason_registry.get_package("angular-language-server"):get_install_path()

lspconfig.angularls.setup({
  cmd = {
    angularls_path .. "/node_modules/@angular/language-server/index.js",
    "--ngProbeLocations",
    vim.fn.getcwd() .. "/node_modules",
    "--tsProbeLocations",
    vim.fn.getcwd() .. "/node_modules",
    "--stdio",
  },
  filetypes = { "typescript", "html" },
  root_dir = lspconfig.util.root_pattern("angular.json", "package.json"),
})
