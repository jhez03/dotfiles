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
-- SEARCH (floating picker: live filtered list as you type, no plugin)
-- ============================================================================
local picker = require("config.picker")

local function list_files()
	local cmd = vim.fn.executable("rg") == 1 and { "rg", "--files", "--hidden", "--glob", "!.git" }
		or { "find", ".", "-type", "f", "-not", "-path", "*/.git/*" }
	local files = vim.fn.systemlist(cmd)
	for i, f in ipairs(files) do
		files[i] = f:gsub("^%./", "")
	end
	return files
end

map("n", "<leader>ff", function()
	picker.open({
		prompt = "Find Files",
		static_items = list_files(),
		on_submit = function(ctx)
			if ctx.item then
				vim.cmd("edit " .. vim.fn.fnameescape(ctx.item))
			end
		end,
	})
end, { desc = "Find files" })

local function rg_search(query)
	if query == "" then
		return {}
	end
	local res = vim
		.system({ "rg", "--vimgrep", "--smart-case", "--hidden", "--glob", "!.git", "--", query }, { text = true })
		:wait()
	if not res or res.code ~= 0 or not res.stdout then
		return {}
	end
	local items = {}
	for line in res.stdout:gmatch("[^\n]+") do
		local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
		if file then
			table.insert(items, { file = file, lnum = tonumber(lnum), col = tonumber(col), text = text })
		end
	end
	return items
end

local function format_match(item)
	return string.format("%s:%d: %s", item.file, item.lnum, item.text)
end

local function require_rg()
	if vim.fn.executable("rg") == 1 then
		return true
	end
	vim.notify("ripgrep (rg) is required for grep search / search & replace", vim.log.levels.ERROR)
	return false
end

map("n", "<leader>sg", function()
	if not require_rg() then
		return
	end
	picker.open({
		prompt = "Grep Search",
		get_items = rg_search,
		format = format_match,
		on_submit = function(ctx)
			if not ctx.item then
				return
			end
			vim.cmd("edit " .. vim.fn.fnameescape(ctx.item.file))
			vim.api.nvim_win_set_cursor(0, { ctx.item.lnum, math.max(ctx.item.col - 1, 0) })
		end,
	})
end, { desc = "Grep search" })

map("n", "<leader>sr", function()
	if not require_rg() then
		return
	end
	picker.open({
		prompt = "Search & Replace (files shown will be affected)",
		get_items = rg_search,
		format = format_match,
		on_submit = function(ctx)
			if #ctx.items == 0 then
				vim.notify("No matches for: " .. ctx.query, vim.log.levels.WARN)
				return
			end
			vim.ui.input({ prompt = string.format("Replace %q with: ", ctx.query) }, function(replace)
				if replace == nil then
					return
				end
				local qf_items, files, seen = {}, {}, {}
				for _, it in ipairs(ctx.items) do
					table.insert(qf_items, { filename = it.file, lnum = it.lnum, col = it.col, text = it.text })
					if not seen[it.file] then
						seen[it.file] = true
						table.insert(files, it.file)
					end
				end
				vim.fn.setqflist({}, " ", { title = "Search & Replace", items = qf_items })
				local pat = vim.fn.escape(ctx.query, "/\\")
				local rep = vim.fn.escape(replace, "/\\")
				vim.cmd(string.format("silent! cfdo %%s/%s/%s/g | update", pat, rep))
				vim.notify(string.format("Replaced %q with %q in %d file(s)", ctx.query, replace, #files))
			end)
		end,
	})
end, { desc = "Search and replace across files" })

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
