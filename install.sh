#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh bash config)

IS_MACOS=false
[[ "$(uname -s)" == "Darwin" ]] && IS_MACOS=true

# --- Install Oh My Zsh if missing (fast, just a git clone; needed on all platforms) ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh not found — installing..."
  KEEP_ZSHRC=yes CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if $IS_MACOS; then
  # --- macOS: bootstrap Homebrew, then everything through it (fast, bottled) ---
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found — installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  if command -v brew &>/dev/null; then
    BREW_FORMULAE=(stow starship herdr hunk zsh-autosuggestions zsh-syntax-highlighting)
    for formula in "${BREW_FORMULAE[@]}"; do
      if ! brew list --formula "$formula" &>/dev/null; then
        echo "Installing $formula..."
        brew install "$formula"
      fi
    done

    # Ghostty terminal + its Nerd Font — meaningless on a headless box, so
    # this whole block only ever runs on macOS.
    BREW_CASKS=(ghostty font-jetbrains-mono-nerd-font)
    for cask in "${BREW_CASKS[@]}"; do
      if ! brew list --cask "$cask" &>/dev/null; then
        echo "Installing $cask..."
        brew install --cask "$cask"
      fi
    done
    PACKAGES+=(ghostty)
  else
    echo "Homebrew install failed — skipping tool installation." >&2
  fi
else
  # --- Linux/VM/workspace: no Homebrew bootstrap — it's slow (builds its own
  # toolchain from scratch) and not guaranteed to have sudo/build-essential in
  # an ephemeral container. Use lighter native installs instead; herdr/hunk
  # and Ghostty are skipped here since they don't have a non-Homebrew install
  # path / don't apply to a headless box. .zshrc guards all of this being
  # absent, so a partial install here still leaves a working shell.
  SUDO=""
  [[ "$(id -u)" -ne 0 ]] && command -v sudo &>/dev/null && SUDO="sudo"

  if ! command -v stow &>/dev/null; then
    if command -v apt-get &>/dev/null; then
      ($SUDO apt-get update -qq && $SUDO apt-get install -y -qq stow) || true
    elif command -v dnf &>/dev/null; then
      $SUDO dnf install -y -q stow || true
    elif command -v apk &>/dev/null; then
      $SUDO apk add --quiet stow || true
    fi
  fi

  if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" || true
  fi

  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
      git clone --quiet --depth 1 "https://github.com/zsh-users/$plugin" "$ZSH_CUSTOM/plugins/$plugin" || true
    fi
  done
fi

# --- Symlink dotfiles into place with stow ---
if command -v stow &>/dev/null; then
  cd "$DOTFILES_DIR"
  # Homebrew/Oh My Zsh's installers may have dropped plain files where our
  # symlinks need to go; stow refuses to clobber those, so move them aside.
  for f in .zshrc .zshenv .bash_profile .bashrc .profile \
           .config/herdr/config.toml .config/hunk/config.toml \
           .config/starship.toml .config/ghostty/config; do
    if [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]]; then
      mkdir -p "$(dirname "$HOME/$f.pre-dotfiles")"
      mv "$HOME/$f" "$HOME/$f.pre-dotfiles"
      echo "Moved existing ~/$f to ~/$f.pre-dotfiles"
    fi
  done
  stow -t "$HOME" -d "$DOTFILES_DIR" "${PACKAGES[@]}"
  echo "Stowed: ${PACKAGES[*]}"
else
  # No package manager access to install stow (e.g. no sudo in this
  # container) — fall back to symlinking each package's files by hand.
  echo "stow not found — symlinking manually instead." >&2
  for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r -d '' src; do
      rel="${src#"$DOTFILES_DIR"/"$pkg"/}"
      dest="$HOME/$rel"
      mkdir -p "$(dirname "$dest")"
      [[ -f "$dest" && ! -L "$dest" ]] && mv "$dest" "$dest.pre-dotfiles"
      ln -sf "$src" "$dest"
    done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
  done
  echo "Manually symlinked: ${PACKAGES[*]}"
fi

echo "Done. Start a new shell (e.g. 'exec zsh -l') to pick up the changes."
