return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        visible = true,
      },
      window = {
        mappings = {
          ["t"] = "open_terminal",
        },
      },
      commands = {
        open_terminal = function(state)
          local node = state.tree:get_node()
          local dir = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
          require("snacks").terminal(nil, { cwd = dir })
        end,
      },
    },
  },
}
