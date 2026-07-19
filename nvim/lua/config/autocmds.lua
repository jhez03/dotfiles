local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on prose filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- close common utility buffers with q
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "notify" },
	callback = function(args)
		vim.opt_local.buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
	end,
})

-- netrw file operations: Tab to mark, c to copy marked here, m to move marked
-- here, Y to duplicate the file/dir under cursor under a new name.
--
-- Marking (Tab) uses netrw's own NetrwMarkFile (via the public netrw#Call()
-- API, see :help netrw and autoload/netrw.vim) purely for the visual
-- highlight; the actual copy/move is done ourselves with cp/mv rather than
-- netrw's NetrwMarkFileCopy/Move. Reason: in tree-listing mode, both mt
-- (set target) and mc/mm re-derive "current directory" from the cursor's
-- row via NetrwGetCurdir(), so setting a target and invoking the copy from
-- the same cursor position (exactly our "press c while sitting on the
-- destination" UX) makes target == curdir, which netrw treats as an
-- in-place rename instead of a cross-directory copy. Doing the file I/O
-- ourselves sidesteps that.
local function suggest_duplicate_name(name)
	local base, ext = name:match("^(.*)(%.[^./]+)$")
	if base and base ~= "" then
		return base .. "_copy" .. ext
	end
	return name .. "_copy"
end

-- NetrwGetCurdir() is cursor-row-dependent in tree-listing mode: if the
-- cursor sits on a directory entry it returns THAT directory's own path;
-- if it sits on a file it returns the file's parent. That's exactly
-- "the directory implied by wherever the cursor is", trimmed of the
-- trailing slash netrw always includes.
local function netrw_dir_at_cursor()
	local curdir = vim.fn["netrw#Call"]("NetrwGetCurdir", 1)
	return (curdir:gsub("/$", ""))
end

-- Absolute path of the specific entry under the cursor (file or directory).
local function netrw_entry_at_cursor()
	local word = vim.fn["netrw#Call"]("NetrwGetWord")
	if word == "" then
		return nil
	end
	if word:match("/$") then
		-- cursor is on a directory: NetrwGetCurdir() already resolved to it
		return netrw_dir_at_cursor()
	end
	-- cursor is on a file: NetrwGetCurdir() gives its parent
	local curdir = vim.fn["netrw#Call"]("NetrwGetCurdir", 1)
	return (vim.fn["netrw#fs#ComposePath"](curdir, word))
end

local function netrw_refresh()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
end

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "netrw",
	callback = function(args)
		local opts = { buffer = args.buf, silent = true, nowait = true }
		local marks = {} -- absolute source paths marked with <Tab> in this buffer

		vim.keymap.set("n", "<Tab>", function()
			local word = vim.fn["netrw#Call"]("NetrwGetWord")
			if word == "" then
				return
			end
			local abspath = netrw_entry_at_cursor()
			if not abspath then
				return
			end
			vim.fn["netrw#Call"]("NetrwMarkFile", 1, word) -- visual highlight only
			for i, p in ipairs(marks) do
				if p == abspath then
					table.remove(marks, i)
					return
				end
			end
			table.insert(marks, abspath)
		end, vim.tbl_extend("force", opts, { desc = "Mark file/dir under cursor" }))

		local function apply_to_marks(label, build_cmd)
			if #marks == 0 then
				vim.notify("No marked files (Tab to mark)", vim.log.levels.WARN)
				return
			end
			local target = netrw_dir_at_cursor()
			for _, src in ipairs(marks) do
				local dst = target .. "/" .. vim.fn.fnamemodify(src, ":t")
				if vim.fn.simplify(src) ~= vim.fn.simplify(dst) then
					vim.fn.system(build_cmd(src, dst))
					if vim.v.shell_error ~= 0 then
						vim.notify(label .. " failed for: " .. src, vim.log.levels.ERROR)
					end
				end
			end
			vim.fn["netrw#Call"]("NetrwUnmarkList", vim.api.nvim_get_current_buf(), vim.fn["netrw#Call"]("NetrwGetCurdir", 1))
			marks = {}
			netrw_refresh()
		end

		vim.keymap.set("n", "c", function()
			apply_to_marks("Copy", function(src, dst)
				return vim.fn.isdirectory(src) == 1 and { "cp", "-r", src, dst } or { "cp", src, dst }
			end)
		end, vim.tbl_extend("force", opts, { desc = "Copy marked file(s) here" }))

		vim.keymap.set("n", "m", function()
			apply_to_marks("Move", function(src, dst)
				return { "mv", src, dst }
			end)
		end, vim.tbl_extend("force", opts, { desc = "Move marked file(s) here" }))

		vim.keymap.set("n", "Y", function()
			local src = netrw_entry_at_cursor()
			if not src then
				return
			end
			local base = vim.fn.fnamemodify(src, ":t")
			local parent = vim.fn.fnamemodify(src, ":h")
			vim.ui.input({ prompt = "Duplicate '" .. base .. "' as: ", default = suggest_duplicate_name(base) }, function(newname)
				if not newname or newname == "" or newname == base then
					return
				end
				local dst = parent .. "/" .. newname
				vim.fn.system(vim.fn.isdirectory(src) == 1 and { "cp", "-r", src, dst } or { "cp", src, dst })
				if vim.v.shell_error ~= 0 then
					vim.notify("Duplicate failed for: " .. base, vim.log.levels.ERROR)
					return
				end
				netrw_refresh()
			end)
		end, vim.tbl_extend("force", opts, { desc = "Duplicate file/dir under cursor" }))
	end,
})

-- equalize splits when the terminal/window is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})
