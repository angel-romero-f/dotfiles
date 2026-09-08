#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh bash config)

# --- Install Homebrew if missing ---
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found — installing..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# --- Install CLI tools this dotfiles repo configures ---
if command -v brew &>/dev/null; then
  BREW_FORMULAE=(stow starship herdr hunk zsh-autosuggestions zsh-syntax-highlighting)
  for formula in "${BREW_FORMULAE[@]}"; do
    if ! brew list --formula "$formula" &>/dev/null; then
      echo "Installing $formula..."
      brew install "$formula"
    fi
  done
else
  echo "Homebrew install failed — skipping tool installation." >&2
fi

# --- Install Oh My Zsh if missing ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh not found — installing..."
  KEEP_ZSHRC=yes CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- Symlink dotfiles into place with stow ---
if command -v stow &>/dev/null; then
  cd "$DOTFILES_DIR"
  # Homebrew/Oh My Zsh's installers may have dropped plain files where our
  # symlinks need to go; stow refuses to clobber those, so move them aside.
  for f in .zshrc .zshenv .bash_profile .bashrc .profile; do
    if [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]]; then
      mv "$HOME/$f" "$HOME/$f.pre-dotfiles"
      echo "Moved existing ~/$f to ~/$f.pre-dotfiles"
    fi
  done
  stow -t "$HOME" -d "$DOTFILES_DIR" "${PACKAGES[@]}"
  echo "Stowed: ${PACKAGES[*]}"
else
  echo "stow not found — could not symlink dotfiles." >&2
  exit 1
fi

echo "Done. Start a new shell (e.g. 'exec zsh -l') to pick up the changes."
