# dotfiles

Personal dev environment config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Keeps my general setup (shell, terminal tools) reproducible on any machine —
no company-internal config lives here.

## Layout

Each top-level directory is a stow "package" mirroring `$HOME`:

- `zsh/` — `.zshrc`, `.zshenv`
- `bash/` — `.bash_profile`, `.bashrc`, `.profile`
- `config/` — CLI tool configs under `~/.config/` (herdr, hunk, starship)

## Usage

```sh
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

This bootstraps Homebrew and Oh My Zsh if they're missing, installs the CLI
tools referenced here (via Homebrew), and symlinks everything into place with
`stow`. Not handled (terminal-specific, not scriptable end-to-end): installing
a Nerd Font and setting it in your terminal emulator's preferences.

To add/remove a package manually:

```sh
cd ~/dotfiles
stow zsh          # symlink
stow -D zsh       # unlink
```
