#!/usr/bin/env bash
# Symlinks configs into place and installs plugins/tools headlessly.
# Safe to re-run (idempotent). Called at image build time and usable manually.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Symlink configs into standard locations ------------------------------------
mkdir -p "$HOME/.config" "$HOME/.config/tmux" "$HOME/.config/lazygit"
ln -sfn "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"
ln -sfn "$DOTFILES/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
#tmux.conf sources ~/.tmux.conf and loads TPM from ~/.tmux/plugins/tpm,
# so mirror the config to ~/.tmux.conf as well.
ln -sfn "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DOTFILES/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

# 2. tmux plugin manager (TPM) + plugins ----------------------------------------
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || true

# 3. Neovim: sync plugins + install Mason tools (headless) ----------------------
# nvim --headless "+Lazy! sync" +qa || true
# nvim --headless "+MasonInstall emmet-ls intelephense" +qa || true

echo "install.sh complete."
