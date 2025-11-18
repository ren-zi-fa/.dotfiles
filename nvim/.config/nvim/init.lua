
vim.opt.number = true
vim.opt.relativenumber = true

-- Warna dan tampilan
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

-- Indentasi dan format otomatis
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Encoding dan file
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- ================================
-- ======== MOUSE & CLIPBOARD =====
-- ================================

vim.opt.mouse = "a"                  -- Bisa klik, drag, scroll, copy
vim.opt.clipboard = "unnamedplus"    -- Integrasi clipboard sistem


-- ================================
-- ========== KEYBINDING ==========
-- ================================

-- Simpan file (Ctrl+S)
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })

-- Select all (Ctrl+A)
vim.api.nvim_set_keymap('n', '<C-a>', 'ggVG', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-a>', '<Esc>ggVG', { noremap = true, silent = true })

-- Undo (Ctrl+Z)
vim.api.nvim_set_keymap('n', '<C-z>', 'u', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-z>', '<Esc>u', { noremap = true, silent = true })

-- Redo (Ctrl+Y)
vim.api.nvim_set_keymap('n', '<C-y>', '<C-r>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-y>', '<Esc><C-r>', { noremap = true, silent = true })

