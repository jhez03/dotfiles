-- Minimal, dependency-free fuzzy picker: a floating prompt + floating results
-- list that updates live as you type. Built entirely on core Neovim APIs
-- (prompt-buffer, floating windows, vim.system) — no plugin.
local M = {}

local ns = vim.api.nvim_create_namespace("picker_selection")
local PROMPT = "> "

local state = {
	prompt_buf = nil,
	prompt_win = nil,
	results_buf = nil,
	results_win = nil,
	items = {},
	selected = 1,
	timer = nil,
}

local function close()
	if state.timer then
		state.timer:stop()
		state.timer:close()
		state.timer = nil
	end
	for _, win in ipairs({ state.prompt_win, state.results_win }) do
		if win and vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end
	state.prompt_win, state.results_win = nil, nil
	state.prompt_buf, state.results_buf = nil, nil
end

local function render()
	local items, format = state.items, state.format
	if state.selected > #items then
		state.selected = math.max(1, #items)
	end

	local lines = {}
	for i, item in ipairs(items) do
		lines[i] = format(item)
	end
	if #lines == 0 then
		lines = { "-- no results --" }
	end

	vim.bo[state.results_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.results_buf, 0, -1, false, lines)
	vim.bo[state.results_buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(state.results_buf, ns, 0, -1)
	if #items > 0 then
		vim.api.nvim_buf_add_highlight(state.results_buf, ns, "PmenuSel", state.selected - 1, 0, -1)
		if state.results_win and vim.api.nvim_win_is_valid(state.results_win) then
			pcall(vim.api.nvim_win_set_cursor, state.results_win, { state.selected, 0 })
		end
	end
end

-- subsequence fuzzy match; smaller span = tighter/better match
local function fuzzy_score(text, query)
	text, query = text:lower(), query:lower()
	local ti, qi, first, last = 1, 1, nil, nil
	while ti <= #text and qi <= #query do
		if text:sub(ti, ti) == query:sub(qi, qi) then
			first = first or ti
			last = ti
			qi = qi + 1
		end
		ti = ti + 1
	end
	if qi > #query then
		return last - first
	end
	return nil
end

local function default_filter(items, query, format)
	if query == "" then
		return items
	end
	local scored = {}
	for _, item in ipairs(items) do
		local score = fuzzy_score(format(item), query)
		if score then
			table.insert(scored, { item = item, score = score })
		end
	end
	table.sort(scored, function(a, b)
		return a.score < b.score
	end)
	local out = {}
	for _, s in ipairs(scored) do
		table.insert(out, s.item)
	end
	return out
end

-- exposed so callers can fuzzy-filter a freshly-computed list themselves
-- (e.g. a buffer list that must be re-enumerated after a delete action)
M.filter = default_filter

local function get_query()
	local line = vim.api.nvim_buf_get_lines(state.prompt_buf, 0, 1, false)[1] or ""
	return line:sub(#PROMPT + 1)
end

local function refresh()
	if not (state.prompt_buf and vim.api.nvim_buf_is_valid(state.prompt_buf)) then
		return
	end
	local query = get_query()
	if state.get_items then
		state.items = state.get_items(query)
	else
		state.items = default_filter(state.static_items or {}, query, state.format)
	end
	render()
end

local function move(delta)
	if #state.items == 0 then
		return
	end
	state.selected = ((state.selected - 1 + delta) % #state.items) + 1
	vim.api.nvim_buf_clear_namespace(state.results_buf, ns, 0, -1)
	vim.api.nvim_buf_add_highlight(state.results_buf, ns, "PmenuSel", state.selected - 1, 0, -1)
	pcall(vim.api.nvim_win_set_cursor, state.results_win, { state.selected, 0 })
end

--- opts:
---   prompt        title shown on the results window border
---   static_items  full candidate list, filtered client-side as you type (fuzzy)
---   get_items(query)  OR: compute the list fresh per query (e.g. shelling out to rg)
---   format(item)  -> display string (default: tostring)
---   on_submit(ctx) ctx = { query, item (currently highlighted, may be nil), items }
---   actions        map of lhs -> function(ctx); runs in place and refreshes the
---                   list afterwards (picker stays open) — e.g. delete-buffer on <C-d>
function M.open(opts)
	close()

	state.format = opts.format or tostring
	state.static_items = opts.static_items
	state.get_items = opts.get_items
	state.selected = 1
	state.items = {}

	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	state.results_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.results_buf].bufhidden = "wipe"
	state.results_win = vim.api.nvim_open_win(state.results_buf, false, {
		relative = "editor",
		width = width,
		height = height - 2,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " " .. (opts.prompt or "Picker") .. " ",
		title_pos = "center",
	})

	state.prompt_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.prompt_buf].bufhidden = "wipe"
	vim.bo[state.prompt_buf].buftype = "prompt"
	vim.fn.prompt_setprompt(state.prompt_buf, PROMPT)
	state.prompt_win = vim.api.nvim_open_win(state.prompt_buf, true, {
		relative = "editor",
		width = width,
		height = 1,
		row = row + height - 1,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.fn.prompt_setcallback(state.prompt_buf, function(_)
		local query = get_query()
		local item = state.items[state.selected]
		local items = state.items
		close()
		if opts.on_submit then
			opts.on_submit({ query = query, item = item, items = items })
		end
	end)
	vim.fn.prompt_setinterrupt(state.prompt_buf, close)

	local map_opts = { buffer = state.prompt_buf, nowait = true }
	vim.keymap.set({ "i", "n" }, "<C-j>", function()
		move(1)
	end, map_opts)
	vim.keymap.set({ "i", "n" }, "<C-k>", function()
		move(-1)
	end, map_opts)
	vim.keymap.set({ "i", "n" }, "<Down>", function()
		move(1)
	end, map_opts)
	vim.keymap.set({ "i", "n" }, "<Up>", function()
		move(-1)
	end, map_opts)
	vim.keymap.set({ "i", "n" }, "<Esc>", close, map_opts)

	if opts.actions then
		for lhs, fn in pairs(opts.actions) do
			vim.keymap.set({ "i", "n" }, lhs, function()
				local ctx = { query = get_query(), item = state.items[state.selected], items = state.items }
				fn(ctx)
				refresh()
			end, map_opts)
		end
	end

	if opts.get_items then
		vim.api.nvim_create_autocmd("TextChangedI", {
			buffer = state.prompt_buf,
			callback = function()
				if state.timer then
					state.timer:stop()
					state.timer:close()
				end
				state.timer = vim.uv.new_timer()
				state.timer:start(
					80,
					0,
					vim.schedule_wrap(function()
						state.timer = nil
						refresh()
					end)
				)
			end,
		})
	else
		vim.api.nvim_create_autocmd("TextChangedI", {
			buffer = state.prompt_buf,
			callback = refresh,
		})
	end

	vim.cmd("startinsert!")
	refresh()
end

return M
