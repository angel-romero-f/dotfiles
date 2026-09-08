#!/usr/bin/env bash
set -uo pipefail  # no -e: one failed tool install shouldn't block the rest, or the symlinking below

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh bash config)

# Oh My Zsh (just a git clone, works the same everywhere)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  KEEP_ZSHRC=yes CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ "$(uname -s)" == "Darwin" ]]; then
  # macOS: bootstrap Homebrew, then install everything through it
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
  brew install stow starship herdr hunk glow zsh-autosuggestions zsh-syntax-highlighting
  brew install --cask ghostty font-jetbrains-mono-nerd-font
  PACKAGES+=(ghostty)
else
  # Linux/VM: no Homebrew — install the same tools natively instead
  command -v stow &>/dev/null || sudo apt-get install -y stow
  command -v starship &>/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || git clone -q https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || git clone -q https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

  export PATH="$HOME/.local/bin:$PATH"
  command -v herdr &>/dev/null || curl -fsSL https://herdr.dev/install.sh | sh

  command -v npm &>/dev/null || { curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs; }
  npm config set prefix "$HOME/.local"  # global npm dir may not be user-writable otherwise
  command -v hunk &>/dev/null || npm i -g hunkdiff  # published as hunkdiff; binary is `hunk`

  if ! command -v glow &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    GLOW_VERSION=$(curl -fsSL https://api.github.com/repos/charmbracelet/glow/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -fsSL "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_x86_64.tar.gz" | tar xz -C "$HOME/.local/bin" glow
  fi

  # Ghostty is macOS-only: no point configuring a GUI terminal on a headless box.
fi

command -v herdr &>/dev/null && herdr integration install claude

# Symlink dotfiles into place
for f in .zshrc .zshenv .bash_profile .bashrc .profile \
         .config/herdr/config.toml .config/hunk/config.toml \
         .config/starship.toml .config/ghostty/config; do
  [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]] && mv "$HOME/$f" "$HOME/$f.pre-dotfiles"
done
stow -t "$HOME" -d "$DOTFILES_DIR" "${PACKAGES[@]}"
echo "Stowed: ${PACKAGES[*]}"
