# dotfiles

Personal dotfiles for setting up a consistent terminal environment on **macOS** and **Linux**.

## What this repo manages

- Shell setup: `zsh`, Zim modules, aliases
- Prompt and navigation: `starship`, `zoxide`
- Terminal + tooling config: `kitty`, `tmux`, `git`, `neovim`
- Package installation:
  - macOS via `Brewfile` (Homebrew)
  - Arch Linux via `Pacmanfile` (pacman) + `Aurfile` (yay/AUR)

## Quick start

```bash
git clone https://github.com/minhuy206/dotfiles.git
cd dotfiles
./install.sh
```

## Installer options

```bash
./install.sh --help
./install.sh --no-remote-install
./install.sh --allow-remote-install
./install.sh --skip-git-config
./install.sh --git-name "Your Name" --git-email "you@example.com" --git-default-branch main
```

- `--no-remote-install` disables remote installer scripts (affects Homebrew on macOS and the yay-bin bootstrap on Arch).
- `--allow-remote-install` is the default behavior.
- `--skip-git-config` skips git identity/default branch prompts and leaves `~/.gitconfig` untouched.
- `--git-name`, `--git-email`, and `--git-default-branch` override git identity/default branch values set in `~/.gitconfig`.
- If git options are missing and the installer is run interactively, it prompts for the missing values with detected defaults.

## What `install.sh` does

1. Detects OS (`macOS` or `Arch Linux`)
2. Installs packages (`brew bundle` on macOS; `pacman` + `yay` on Arch)
3. Prompts for (or accepts flags for) git name/email/default branch, then updates `user.name`, `user.email`, and `init.defaultBranch` in `~/.gitconfig` unless `--skip-git-config` is used
4. Symlinks dotfiles into `$HOME` (with backup for existing files)
5. On Arch, attempts to set `zsh` as login shell

## Managed files

- `.zshrc`
- `.zshenv`
- `.zimrc`
- `.tmux.conf`
- `.config/zsh/00-options.zsh`
- `.config/zsh/10-zim.zsh`
- `.config/zsh/20-path.zsh`
- `.config/zsh/30-aliases.zsh`
- `.config/zsh/40-tools.zsh`
- `.config/zsh/50-tmux.zsh`
- `.config/zsh/99-zoxide.zsh`
- `.config/nvim`
- `.config/starship/starship.toml`
- `.config/kitty/kitty.conf`

## Notes

- **Fonts:** macOS installs **JetBrainsMono Nerd Font** via the Brewfile cask (`font-jetbrains-mono-nerd-font`). Arch Linux installs **JetBrainsMono Nerd Font** via pacman (`ttf-jetbrains-mono-nerd` from Pacmanfile).
- Existing config files are backed up with a timestamp suffix before replacement.
- `install.sh` only updates `user.name`, `user.email`, and `init.defaultBranch` in `~/.gitconfig`, leaving any other settings intact (it does not symlink `~/.gitconfig` from the repo).
- **Neovim >= 0.12** is required for the LSP config (`vim.lsp.config`/`vim.lsp.enable` API).
- On first `nvim` launch, `lazy.nvim` installs the configured plugin set.
- On first `nvim` launch, Mason automatically installs Verible for SystemVerilog linting, formatting, and LSP support.
- Tcl buffers use Tree-sitter highlighting and the `tclsp` language server from `tclint`.
- Neovim wires up **Verible** and **tclsp** (`tclint`) when `verible-verilog-ls` and `tclsp` are on your PATH (see `lazy.nvim` LSP plugin config).
- SystemVerilog/Verilog buffers use `verible-verilog-ls`, `verible-verilog-format`, and `verible-verilog-lint` through Neovim.
- Interactive `zsh` shells auto-attach/start `tmux` session `main` when available. Set `DISABLE_AUTO_TMUX=1` to skip it.
