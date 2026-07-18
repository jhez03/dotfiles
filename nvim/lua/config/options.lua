-- ============================================================================
-- UI
-- ============================================================================
vim.opt.number = true -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.signcolumn = "yes" -- always show sign column (avoids text shift)
vim.opt.termguicolors = true -- true color support
vim.opt.laststatus = 3 -- single global statusline
vim.opt.showmode = false -- mode already implied by statusline/cmdline
vim.opt.pumheight = 10 -- popup menu height
vim.opt.wrap = false -- do not wrap lines by default
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 columns left/right of cursor

-- ============================================================================
-- INDENTATION
-- ============================================================================
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- ============================================================================
-- SEARCH
-- ============================================================================
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "nosplit" -- live preview of :s substitutions

-- ============================================================================
-- FILES
-- ============================================================================
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.undofile = true
vim.opt.undodir = undodir
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.autoread = true

-- ============================================================================
-- BEHAVIOR
-- ============================================================================
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.confirm = true -- prompt to save instead of erroring on :q with changes
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- Native omnifunc completion works without any completion plugin (<C-x><C-o>)
vim.opt.completeopt = "menu,menuone,noselect"

-- ============================================================================
-- FILE / GREP SEARCH (built-in :find and :grep, no fuzzy-finder plugin)
-- ============================================================================
vim.opt.path:append("**") -- recursive search for :find
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full" -- tab-complete like a fuzzy picker
vim.opt.wildignore:append({ ".git/*", "node_modules/*", "*.o", "*.pyc" })

-- Prefer ripgrep for :grep if it's on $PATH; otherwise falls back to the
-- system default grepprg (still works, just slower / no --hidden support).
if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
	vim.opt.grepformat = "%f:%l:%c:%m"
end

-- ============================================================================
-- FILE EXPLORER (built-in netrw, used as a tree sidebar via :Lexplore)
-- ============================================================================
vim.g.netrw_banner = 0 -- no help banner
vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_winsize = 25 -- sidebar width (% of editor)
vim.g.netrw_browse_split = 0 -- open files in the previous window
vim.g.netrw_altv = 1 -- open splits to the right
