# Copilot Instructions

## Build, test, and lint commands

This repository has no formal build/test/lint pipeline. Use installer/script checks:

```bash
./install.sh --help
bash -n install.sh
```

Single-file shell config check:

```bash
source .config/zsh/aliases.zsh
```

## High-level architecture

- `install.sh` is the orchestrator:
  - detects OS
  - installs packages (`Brewfile` on macOS, `Aptfile` + Linux fallbacks)
  - collects git identity/default branch (prompts only for values not passed via CLI overrides)
  - writes `~/.gitconfig`
  - links config files into `$HOME`
- Runtime behavior is split across:
  - `.zshrc` (bootstrap + conditional initialization)
  - `.zimrc` (Zim module ordering/plugins)
  - `.config/zsh/aliases.zsh` (tool-aware aliases)
  - `.config/starship/starship.toml`, `.config/kitty/kitty.conf`, `.tmux.conf`

Cross-file flow: package install -> git config generation -> symlink dotfiles -> shell startup loads linked files and only enables features for installed binaries.

## Key conventions

- Keep `install.sh` in strict mode (`set -euo pipefail`) and function-based structure.
- Linux installers are intentionally two-stage: apt package install first, then `SCRIPT_PRIORITY_PACKAGES` fallback installers.
- Remote script installs must respect `--allow-remote-install` / `--no-remote-install`.
- Dotfile replacement behavior is conservative: existing files are timestamp-backed up before replacement.
- `~/.gitconfig` is **generated** during install (from prompts/flags), not symlinked from repository state.
- In shell configs, always guard tool-specific setup with command-existence checks (e.g. `(( ${+commands[tool]} ))`).
