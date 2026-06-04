# Repository Guidelines

## Project Structure & Module Organization

This is a personal dotfiles repository for macOS and Arch Linux. `install.sh` is the main installer and orchestration entry point. Reusable shell logic lives in `lib/`, split by responsibility such as OS detection, package installation, git config, and symlink handling.

Root package manifests define installed tools: `Brewfile` for macOS, `Pacmanfile` for Arch repo packages, `Aurfile` for AUR packages, and `Pipxfile` for pipx tools. User configuration lives under `.config/`, including `zsh`, `nvim`, `hypr`, `waybar`, `kitty`, `rofi`, `mako`, and `starship`. Wallpaper assets live in `wallpapers/`.

## Build, Test, and Development Commands

There is no formal build pipeline. Use syntax and installer checks before submitting changes:

```bash
./install.sh --help
bash -n install.sh && for f in lib/*.sh; do bash -n "$f"; done
zsh -n .zshrc && for f in .config/zsh/*.zsh; do zsh -n "$f"; done
```

Run `./install.sh --skip-git-config` for an install smoke test that avoids modifying git identity settings. Use `./install.sh --no-remote-install` when testing without remote bootstrap scripts.

## Coding Style & Naming Conventions

Keep shell scripts in strict mode where applicable: `set -euo pipefail`. Prefer small functions, quoted variables, and explicit OS branches. In zsh startup fragments, guard tool-specific setup with command checks such as `(( ${+commands[zoxide]} ))`.

Name shell library files by responsibility, for example `packages_arch.sh` or `git_config.sh`. Keep Neovim Lua modules under `.config/nvim/lua/minhuy/`; plugin specs belong in `.config/nvim/lua/minhuy/plugins/`.

## Testing Guidelines

No coverage target is defined. Treat syntax checks as the minimum required validation. For installer behavior, test the relevant flag path and verify conservative behavior: existing destination files should be backed up before replacement, and `~/.gitconfig` should be updated only through installer prompts or flags, never symlinked.

## Commit & Pull Request Guidelines

Recent commits use short, focused summaries such as `Update Hyprland monitor profile` and `Fix install.sh aborting after pacman when no packages were skipped`. Follow that style: one concise subject, imperative when natural, scoped to the changed behavior.

Pull requests should describe the changed config or install behavior, list tested commands, and note OS impact. Include screenshots only for visible UI changes such as Hyprland, Waybar, Rofi, or terminal theme updates.

## Agent-Specific Instructions

For questions about libraries, frameworks, SDKs, APIs, CLI tools, or cloud services, use Context7 MCP first: resolve the library ID, query the docs, then answer from the fetched documentation.
