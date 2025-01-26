return {
  "mg979/vim-visual-multi",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    vim.g.VM_default_mapping = 0
    vim.g.VM_add_cursor_at_pos_no_mappings = 1
  end,
}
