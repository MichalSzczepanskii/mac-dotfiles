-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
-- Map jk to esc
map("i", "jk", "<esc>", { noremap = true, silent = true })

-- jumps
map("n", "<leader>jt", "<cmd>/template:<cr><cmd>nohl<cr>", { desc = "Jump to template" })
map("n", "<leader>js", "<cmd>/style.:<cr><cmd>nohl<cr>", { desc = "Jump to styles" })
map("n", "<leader>jc", "<cmd>/Component {<cr><cmd>nohl<cr>", { desc = "Jump to component" })

local telescope = require("telescope.builtin")

map("n", "<leader>t?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently open files" })
map("n", "<leader>tsd", telescope.diagnostics, { desc = "[S]earch [D]iagnostics" })
map("n", "<C-e>", LazyVim.pick("buffers"), { desc = "Opened buffers" })
map("n", "<C-F>", LazyVim.pick("live_grep"), { desc = "Search in files" })
