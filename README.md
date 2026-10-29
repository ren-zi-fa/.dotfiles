# Dotfiles

Dotfiles configuration for a development environment on a VPS (Debian/Ubuntu).

## Overview

- **zsh** — Zsh + Oh My Zsh + Powerlevel10k + plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- **tmux** — tmux configuration
- **nvim** — Neovim configuration (submodule)
- **rofi** — Rofi launcher theme
- **alacritty** — Alacritty terminal configuration
- **setup.sh** — automated system packages and dotfiles installation

## Requirements

- Debian / Ubuntu
- `sudo` access
- Internet connection

## Usage

### Full installation

1. Clone the repository:

   ```sh
   git clone git@github.com:ren-zi-fa/.dotfiles.git ~/.dotfiles
   ```

2. Run the setup script:

   ```sh
   cd ~/.dotfiles && chmod +x ./setup.sh && ./setup.sh
   ```

   The script installs system packages, eza, Neovim, Oh My Zsh,
   Powerlevel10k, zsh plugins, Composer, and tldr; links the dotfiles to
   `$HOME` using GNU Stow; then sets zsh as the default shell.

3. Reload the shell:

   ```sh
   exec zsh
   ```

### Link dotfiles only (without installing packages)

```sh
cd ~/.dotfiles
stow --dir="$HOME/.dotfiles" --target="$HOME" tmux zsh nvim
```
