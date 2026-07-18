# nvim (minimal, no plugins)

A from-scratch Neovim config with no plugin manager and no plugins — just
built-in `vim.opt`/`vim.keymap`/`vim.api`, with keymaps modeled after LazyVim's
defaults.

## Requirements

- Neovim (built-in only for everything except grep search)
- `ripgrep` (`rg`) optional — used by `<leader>sg`/`<leader>sr` if present, otherwise falls back to system `grep` (slower, no `--hidden`)

## Structure

```
init.lua               -- bootstraps the three modules below
lua/config/options.lua -- vim.opt settings
lua/config/keymaps.lua -- keymaps
lua/config/autocmds.lua-- autocommands
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
| `<leader>ff` | Find files (`:find`, tab-completes via `path=**`) |
| `<leader>sg` | Grep search into quickfix (uses `rg` if installed) |
| `<leader>sr` | Search, then replace across every file with a match |
| `<leader>fn` | New file |
| `<C-s>` | Save file |
| `<leader>qq` | Quit all |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cd` | Line diagnostics float |
| `<leader>xq` | Diagnostic location list |
| `<leader>ft` | Toggle floating terminal |
| `<Esc>` (terminal mode) | Back to normal mode |
| `<Esc>` (normal mode) | Clear search highlight |

## Adding plugins later

Neovim 0.12+ ships with a built-in plugin manager (`vim.pack.add`). Nothing
here depends on plugins, so they can be layered on top without touching
`options.lua`/`keymaps.lua`/`autocmds.lua`.
