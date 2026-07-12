# nvim-lite

A powerful but tastefully minimal Neovim configuration in a single file. No plugin manager. No bloat.

*Author: Radley E. Sidwell-Lewis*

## Requirements

- Neovim `0.12` or later
- A [Nerd Font](https://www.nerdfonts.com/) (FiraCode Nerd Font recommended)
- `git`, `ripgrep`, `fzf`, `fd`
- `go` (for `efm-langserver`)

## Installation

```bash
mkdir -p ~/.config/nvim && curl -fsSL https://raw.githubusercontent.com/radleylewis/nvim-lite/main/init.lua -o ~/.config/nvim/init.lua
```

> **Note:** If you already have a Neovim config, back it up first.

## Dependencies

**Neovim `0.12`** and the **Treesitter CLI**:

```bash
sudo pacman -S neovim tree-sitter-cli
```

**Go** (required by `efm-langserver` for linting and formatting):

```bash
sudo pacman -S go
```

**LuaSnip** (native C dependency for snippet expansion):

```bash
sudo pacman -S lua-jsregexp
```

**General utilities:**

```bash
sudo pacman -S git ripgrep fzf fd
```

**LSP servers** are managed via [Mason](https://github.com/mason-org/mason.nvim). On first launch, open Neovim and run `:Mason` to install the servers you need.

> **Note:** `rust_analyzer` is managed automatically by `rustaceanvim` via `rustup`. Install it with `rustup component add rust-analyzer` rather than through Mason.

## Features

- Single `init.lua` — no plugin manager, uses Neovim's native `vim.pack`
- Treesitter syntax highlighting and folding
- LSP via `nvim-lspconfig` with `blink.cmp` for completion
- Linting and formatting via `efm-langserver`
- Rust support via `rustaceanvim`
- Fuzzy finding via `fzf-lua`
- File tree via `nvim-tree`
- Git integration via `mini.diff` and `mini.git`
- Floating terminal (`<leader>t`)
- Obsidian note-taking support (optional, requires `~/Documents/Notes/`)
- Custom statusline with mode, branch, filetype and file size indicators
- Transparent background

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>t` | Toggle floating terminal |
| `<leader>gd` | Go to definition |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `K` | Hover documentation |
| `]h` / `[h` | Next / previous git hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hb` | Git blame |
| `<C-q>` | Close floating terminal |
