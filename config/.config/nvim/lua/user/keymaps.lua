-- user/keymaps.lua
-- Custom keymaps and shortcuts

local keymap = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "

-- Clear search highlight on pressing Escape
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better pane navigation (if not using vim-tmux-navigator plugin, these still act as defaults)
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Resize splits with arrow keys
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines of text up/down in Visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Save and Quit shortcuts
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit buffer" })

-- Keep cursor in place when joining lines
keymap("n", "J", "mzJ`z")

-- Keep cursor in the center during half-page jumps
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle of the screen
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
