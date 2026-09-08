# dotfiles

Personal dev environment config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Keeps my general setup (shell, terminal tools) reproducible on any machine —
no company-internal config lives here.

## Layout

Each top-level directory is a stow "package" mirroring `$HOME`:

- `zsh/` — `.zshrc`, `.zshenv`, `.p10k.zsh`
- `bash/` — `.bash_profile`, `.bashrc`, `.profile`
- `herdr/` — `~/.config/herdr/config.toml`
- `hunk/` — `~/.config/hunk/config.toml`

## Usage

```sh
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

This installs the CLI tools referenced here (via Homebrew) and symlinks
everything into place with `stow`.

To add/remove a package manually:

```sh
cd ~/dotfiles
stow zsh          # symlink
stow -D zsh       # unlink
```
