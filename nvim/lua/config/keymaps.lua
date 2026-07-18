vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- ============================================================================
-- MOVEMENT
-- ============================================================================
map("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
map("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

map("n", "<Esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- ============================================================================
-- WINDOWS
-- ============================================================================
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ============================================================================
-- BUFFERS
-- ============================================================================
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ============================================================================
-- EDITING
-- ============================================================================
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- ============================================================================
-- FILES
-- ============================================================================
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>e", "<cmd>Lexplore<cr>", { desc = "Toggle file explorer" })

-- ============================================================================
-- SEARCH (built-in :find / :grep / quickfix, no fuzzy-finder plugin)
-- ============================================================================
map("n", "<leader>ff", ":find ", { desc = "Find files" })

local function grep_prompt()
	vim.ui.input({ prompt = "Grep: " }, function(pattern)
		if not pattern or pattern == "" then
			return
		end
		vim.cmd("silent! grep! " .. vim.fn.escape(pattern, " \\|\"'"))
		vim.cmd("copen")
	end)
end
map("n", "<leader>sg", grep_prompt, { desc = "Grep search (quickfix)" })

local function search_and_replace()
	vim.ui.input({ prompt = "Search: " }, function(search)
		if not search or search == "" then
			return
		end
		vim.ui.input({ prompt = "Replace with: " }, function(replace)
			if replace == nil then
				return
			end
			vim.cmd("silent! grep! " .. vim.fn.escape(search, " \\|\"'"))
			if vim.fn.getqflist({ size = 0 }).size == 0 then
				vim.notify("No matches found for: " .. search, vim.log.levels.WARN)
				return
			end
			local pat = vim.fn.escape(search, "/\\")
			local rep = vim.fn.escape(replace, "/\\")
			vim.cmd(string.format("cfdo %%s/%s/%s/g | update", pat, rep))
		end)
	end)
end
map("n", "<leader>sr", search_and_replace, { desc = "Search and replace across files" })

-- ============================================================================
-- DIAGNOSTICS (core vim.diagnostic, works with zero LSP configured)
-- ============================================================================
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xq", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostic location list" })

-- ============================================================================
-- FLOATING TERMINAL (core nvim_open_win + termopen, no plugin)
-- ============================================================================
local terminal_state = { buf = nil, win = nil }

local function toggle_floating_terminal()
	if terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.win = nil
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})

	if vim.bo[terminal_state.buf].buftype ~= "terminal" then
		vim.fn.termopen(os.getenv("SHELL"))
	end
	vim.cmd("startinsert")
end

map("n", "<leader>ft", toggle_floating_terminal, { desc = "Toggle floating terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })
