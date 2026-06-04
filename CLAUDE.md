# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Commands

Syntax-check installer scripts:

```bash
bash -n install.sh scripts/install-macos.sh scripts/install-arch.sh scripts/lib/*.sh
```

Validate zsh config:

```bash
zsh -n shared/zsh/zshrc
for f in shared/zsh/config/*.zsh macos/zsh/*.zsh; do zsh -n "$f"; done
```

Run installers:

```bash
./install.sh
./scripts/install-macos.sh --skip-git-config
./scripts/install-arch.sh --no-remote-install
```

## Architecture

`install.sh` is a thin OS-detecting wrapper that delegates to `scripts/install-macos.sh` or `scripts/install-arch.sh`.

Installer helpers live in `scripts/lib/`:

- `log.sh`, `os.sh`, `args.sh`: shell helpers, OS detection, option parsing
- `packages_common.sh`, `packages_macos.sh`, `packages_arch.sh`: manifest parsing and package installation
- `tools_registry.sh`: required-tool collection and verification
- `git_config.sh`: generated `~/.gitconfig` updates
- `symlink.sh`: conservative symlink helpers and platform link sets
- `install_flow.sh`: shared install-flow helpers

Config layout:

- `shared/`: OS-independent terminal/dev-tool config for zsh, tmux, Neovim, Starship, Kitty, and pipx tools
- `macos/`: Homebrew manifest and macOS-only zsh overlays
- `arch/`: pacman/AUR manifests plus Hyprland/Wayland configs, wallpapers, and related services/configs

Manifest locations:

- `macos/Brewfile`
- `arch/Pacmanfile`
- `arch/Aurfile`
- `shared/Pipxfile`

## Key Conventions

- Keep shell scripts in strict mode (`set -euo pipefail`) where applicable.
- Existing destination files, directories, and conflicting symlinks must be timestamp-backed up before replacement.
- `~/.gitconfig` is generated/updated by the installer and must not be symlinked from this repo.
- Shared configs must not depend on Hyprland, Wayland, or macOS-only tools unless guarded or moved into the platform tree.
- `~/.config/hypr` should remain a real directory so generated monitor files can coexist with symlinked Hyprland config.
- Guard shell tool setup with command checks, for example `(( ${+commands[zoxide]} ))`.

## Neovim

Neovim config lives in `shared/nvim/`. `init.lua` loads `lua/minhuy/init.lua`, which bootstraps settings, remaps, and lazy.nvim. Plugin specs live under `shared/nvim/lua/minhuy/plugins/`.

Neovim requires version 0.12 or newer for the configured LSP APIs.
