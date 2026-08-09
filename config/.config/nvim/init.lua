-- init.lua
-- Main Neovim configuration entry point

-- Set mapleader to Space before requiring plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 1. Bootstrap lazy.nvim (Plugin Manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Load basic settings & keymaps
require("user.options")
require("user.keymaps")

-- 3. Load and initialize plugins via lazy.nvim
require("lazy").setup("user.plugins", {
  change_detection = {
    notify = false, -- don't notify when config files change
  },
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})
