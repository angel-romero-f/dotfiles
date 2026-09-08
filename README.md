# dotfiles

Personal dev environment config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Keeps my general setup (shell, terminal tools) reproducible on any machine —
no company-internal config lives here.

## Layout

Each top-level directory is a stow "package" mirroring `$HOME`:

- `zsh/` — `.zshrc`, `.zshenv`
- `bash/` — `.bash_profile`, `.bashrc`, `.profile`
- `config/` — CLI tool configs under `~/.config/` (herdr, hunk, starship)
- `ghostty/` — Ghostty terminal config (macOS only, see below)

## Usage

```sh
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

This bootstraps Homebrew and Oh My Zsh if they're missing, installs the CLI
tools referenced here (via Homebrew), and symlinks everything into place with
`stow`.

On macOS, it also installs Ghostty and the JetBrains Mono Nerd Font (via
Homebrew casks) and stows the `ghostty` package, so prompt icons/glyphs work
out of the box. This step is skipped entirely on Linux/VMs/workspaces — there's
no terminal emulator to configure there, and Homebrew casks aren't supported
on Linux anyway.

To add/remove a package manually:

```sh
cd ~/dotfiles
stow zsh          # symlink
stow -D zsh       # unlink
```
