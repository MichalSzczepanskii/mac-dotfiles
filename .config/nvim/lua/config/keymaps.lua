-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
-- Map jk to esc
map("i", "jk", "<esc>", { noremap = true, silent = true })

-- jumps
map("n", "<leader>jt", ":edit %<.html<CR>", { desc = "Jump to template", silent = true })
map("n", "<leader>js", ":edit %<.scss<CR>", { desc = "Jump to styles", silent = true })
map("n", "<leader>jc", ":edit %<.ts<CR>", { desc = "Jump to component", silent = true })

local telescope = require("telescope.builtin")

map("n", "<leader>t?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently open files" })
map("n", "<leader>tsd", telescope.diagnostics, { desc = "[S]earch [D]iagnostics" })
map("n", "<C-e>", LazyVim.pick("buffers"), { desc = "Opened buffers" })
map("n", "<C-F>", LazyVim.pick("live_grep"), { desc = "Search in files" })

map("n", "<C-s>", ":wa<cr>", { noremap = true, desc = "Save all", silent = true })

vim.keymap.set("n", "<leader>ft", function()
  local buf_path = vim.fn.expand("%:p:h") -- Get active buffer's directory path
  require("snacks").terminal(nil, { cwd = buf_path })
end, { desc = "Open Terminal in Active Buffer Path" })

vim.keymap.set("i", "<M-l>", "ł", { noremap = true })
vim.keymap.set("i", "<M-o>", "ó", { noremap = true })
