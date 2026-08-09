-- user/options.lua
-- Sane options and settings for Neovim

local opt = vim.opt

-- Line numbers
opt.number = true          -- Show line numbers
opt.relativenumber = true  -- Relative line numbers

-- Tabs & Indentation
opt.tabstop = 4            -- Number of spaces a Tab stands for
opt.shiftwidth = 4         -- Number of spaces used for autoindent
opt.expandtab = true       -- Expand Tab to spaces
opt.smartindent = true     -- Insert indents automatically

-- Search settings
opt.ignorecase = true      -- Case insensitive searching
opt.smartcase = true       -- Smart case (override ignorecase if uppercase entered)
opt.hlsearch = true        -- Keep highlights on search matches

-- Performance & System
opt.termguicolors = true   -- Enable true color support (24-bit RGB colors)
opt.updatetime = 250       -- Faster completion and diagnostics response time
opt.timeoutlen = 300       -- Faster key code sequence timeouts
opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- Smart OSC 52 Clipboard sharing over SSH
if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

-- UI Styling & Theme Settings
opt.background = "dark"    -- FORCE DARK BACKGROUND FOR NORD
opt.signcolumn = "yes"     -- Always show the sign column to prevent text shifts
opt.cursorline = true      -- Highlight the line containing the cursor
opt.wrap = false           -- Disable line wrapping by default
opt.scrolloff = 8          -- Keep at least 8 lines above/below cursor
opt.sidescrolloff = 8      -- Keep at least 8 columns left/right of cursor

-- Sane splitting directions
opt.splitright = true      -- Put new windows to the right of current
opt.splitbelow = true      -- Put new windows below current
