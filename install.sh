#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh bash config)

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
  echo "Homebrew not found — skipping tool installation. Install https://brew.sh first for full setup." >&2
fi

# --- Symlink dotfiles into place with stow ---
if command -v stow &>/dev/null; then
  cd "$DOTFILES_DIR"
  stow -t "$HOME" -d "$DOTFILES_DIR" "${PACKAGES[@]}"
  echo "Stowed: ${PACKAGES[*]}"
else
  echo "stow not found — could not symlink dotfiles." >&2
  exit 1
fi
