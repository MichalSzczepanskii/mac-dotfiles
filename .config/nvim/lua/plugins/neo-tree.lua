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
          ["K"] = "copy_relative_path",
        },
      },
      commands = {
        open_terminal = function(state)
          local node = state.tree:get_node()
          local dir = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
          require("snacks").terminal(nil, { cwd = dir })
        end,
        copy_relative_path = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local root_path = state.path

          -- Remove the root path from the absolute path to get relative path
          local relative_path = filepath:gsub("^" .. vim.pesc(root_path), "")

          -- Copy to clipboard
          vim.fn.setreg("+", relative_path)
          vim.notify("Copied: " .. relative_path)
        end,
      },
    },
  },
}
