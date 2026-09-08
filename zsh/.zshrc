# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
	git
)

source $ZSH/oh-my-zsh.sh

# Homebrew-installed zsh plugins (sourced after oh-my-zsh)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# User configuration

export PATH="$HOME/.trajectory/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Ghostty's terminfo entry isn't installed on this host; fall back to a
# universally supported TERM to avoid line-redraw glitches (e.g. doubled input).
if [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
  export TERM=xterm-256color
fi

# Force certain more-secure behaviours from homebrew
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha

eval "$(starship init zsh)"

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# AWS
export AWS_VAULT_KEYCHAIN_NAME=login
export AWS_SESSION_TTL=24h
export AWS_ASSUME_ROLE_TTL=1h

# Helm
export HELM_DRIVER=configmap

# Load shims (if available)
command -v pyenv &>/dev/null && eval "$(pyenv init - --no-rehash)"
command -v rbenv &>/dev/null && eval "$(rbenv init - --no-rehash)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# Disable XON/XOFF flow control so Ctrl-s is free for use as a tmux/herdr prefix
stty -ixon

# Aliases
alias cdsp="claude --dangerously-skip-permissions"

# Added by Yarn Switch
[ -f "$HOME/.yarn/switch/env" ] && source "$HOME/.yarn/switch/env"
