# Copilot Instructions

## Build, Test, And Lint Commands

This repository has no formal build pipeline. Use syntax checks:

```bash
bash -n install.sh scripts/install-macos.sh scripts/install-arch.sh scripts/lib/*.sh
zsh -n shared/zsh/zshrc
for f in shared/zsh/config/*.zsh macos/zsh/*.zsh; do zsh -n "$f"; done
```

## High-Level Architecture

- `install.sh` detects the OS and delegates to the matching platform installer.
- `scripts/install-macos.sh` installs Homebrew packages, shared pipx tools, shared configs, macOS zsh overlays, and generated git config.
- `scripts/install-arch.sh` installs pacman/AUR packages, shared pipx tools, shared configs, Arch Hyprland/Wayland configs, services, and generated git config.
- Shared reusable helpers live in `scripts/lib/`.

Config roots:

- `shared/`: zsh, tmux, Neovim, Starship, Kitty, and shared pipx tools
- `macos/`: `Brewfile` and macOS-only zsh fragments
- `arch/`: `Pacmanfile`, `Aurfile`, Hyprland, Waybar, Rofi, Mako, Hyprmoncfg, and wallpapers

## Key Conventions

- Remote script installs must respect `--allow-remote-install` and `--no-remote-install`.
- Dotfile replacement behavior is conservative: existing targets are timestamp-backed up before replacement.
- `~/.gitconfig` is generated during install from prompts or flags, never symlinked.
- Keep shared configs OS-independent; move platform-specific setup into `macos/` or `arch/`.
- In shell configs, guard tool-specific setup with command-existence checks.
