#!/usr/bin/env bash
# Bootstrap terminal env on a fresh WSL Arch install.
# Run AFTER cloning the dots bare repo and checking out the `wsl` branch.
#
#   ~/copilot/bootstrap-wsl.sh
#
# Idempotent: safe to re-run.
set -euo pipefail

say() { printf '\n==> %s\n' "$*"; }

say "packages"
# zsh-autosuggestions / zsh-syntax-highlighting must come from pacman: .zshrc
# sources them from /usr/share/zsh/plugins/, which is where the packages land.
sudo pacman -S --needed --noconfirm \
  base-devel git zsh tmux neovim starship fzf zoxide eza ripgrep fd bat jq unzip \
  zsh-autosuggestions zsh-syntax-highlighting zsh-completions

say "tmux plugin manager"
TPM="$HOME/.config/tmux/plugins/tpm"
[ -d "$TPM" ] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"

say "mise (runtime manager: node, python, ...)"
command -v mise >/dev/null || curl -fsSL https://mise.run | sh

say "default shell"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
  echo "   shell changed -- takes effect on next login"
fi

say "copilot cli"
if ! command -v copilot >/dev/null; then
  echo "   install via mise:  mise use -g copilot@latest"
  echo "   then authenticate: copilot  (and run /login)"
fi

cat <<'EOF'

==> done

Remaining manual steps:
  1. tmux: start it, press prefix + I to install plugins
  2. nvim: launch once, let lazy.nvim sync
  3. copilot: mise use -g copilot@latest && copilot   (then /login)
  4. copilot config: ~/copilot/install.sh

Not applicable in WSL (guarded, safe to ignore):
  hypr/waybar/walker/mako configs, the `spm` function (wayland ACLs)
EOF
