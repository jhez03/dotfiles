# nvim (minimal, no plugins)

A from-scratch Neovim config with no plugin manager and no plugins — just
built-in `vim.opt`/`vim.keymap`/`vim.api`, with keymaps modeled after LazyVim's
defaults.

## Requirements

- Neovim (built-in only for everything except grep search)
- `ripgrep` (`rg`) — required for `<leader>sg`/`<leader>sr`; `<leader>ff` falls back to `find` if `rg` isn't installed
- `lazygit` — required for `<leader>gg`

## Structure

```
init.lua               -- bootstraps the three modules below
lua/config/options.lua -- vim.opt settings
lua/config/keymaps.lua -- keymaps
lua/config/autocmds.lua-- autocommands
lua/config/picker.lua  -- minimal floating fuzzy picker used by <leader>ff/sg/sr
```

## Keymaps

Leader is `<Space>`.

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between windows |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>sv` / `<leader>sh` | Split window vertically / horizontally |
| `<C-Up/Down/Left/Right>` | Resize window |
| `<A-j>` / `<A-k>` | Move line/selection down / up |
| `J` / `K` (visual) | Move selection down / up (overrides default visual `J` join) |
| `<leader>x` | Delete without yanking |
| `<leader>p` (visual) | Paste without yanking |
| `<leader>e` | Toggle file explorer (netrw tree sidebar) |
| `<leader>ff` | Find files — floating picker, fuzzy-filters live as you type |
| `<leader>sg` | Grep search — floating picker, live results from `rg` as you type; `<CR>` jumps to match |
| `<leader>sr` | Search & replace — same live picker shows every file/line that matches, `<CR>` then prompts for replacement and applies it across all of them |
| `<leader>fb` | Buffer picker — fuzzy-filter open buffers, `<CR>` switches, `<C-d>` deletes the highlighted buffer without closing the picker |
| `<leader>fd` | Floating directory browser (netrw) for the current file's directory — see netrw keymaps below |
| `<C-j>`/`<C-k>` or `<Up>`/`<Down>` (in picker) | Move selection |
| `<Esc>` (in picker) | Cancel |
| `<leader>fn` | New file |
| `<C-s>` | Save file |
| `<leader>qq` | Quit all |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cd` | Line diagnostics float |
| `<leader>xq` | Diagnostic location list |
| `<leader>ft` | Toggle floating terminal |
| `<leader>gg` | Open lazygit (floating terminal, closes automatically on quit) |
| `<Esc>` (terminal mode) | Back to normal mode |
| `<Esc>` (normal mode) | Clear search highlight |

### netrw keymaps (`<leader>e` sidebar and `<leader>fd` floating browser)

| Key | Action |
|-----|--------|
| `<Tab>` | Mark/unmark file or directory under cursor |
| `c` | Copy marked file(s)/folder(s) to wherever the cursor currently is |
| `m` | Move marked file(s)/folder(s) to wherever the cursor currently is |
| `Y` | Duplicate the file/folder under cursor, prompting for a new name (defaults to `name_copy.ext`) |
| `R` | Rename (native netrw) |
| `D` | Delete (native netrw) |
| `%` / `d` | New file / new directory (native netrw) |
| `-` | Up a directory (native netrw) |

## Adding plugins later

Neovim 0.12+ ships with a built-in plugin manager (`vim.pack.add`). Nothing
here depends on plugins, so they can be layered on top without touching
`options.lua`/`keymaps.lua`/`autocmds.lua`.
