# dotfiles

Personal dotfiles for macOS and Arch Linux, split by platform so shared terminal/dev-tool config stays reusable without pulling in Hyprland-only files.

## Repository Structure

```text
dotfiles/
├── install.sh                  # OS-detecting wrapper
├── scripts/
│   ├── install-macos.sh
│   ├── install-arch.sh
│   └── lib/                    # installer helpers
├── shared/
│   ├── nvim/
│   ├── starship/
│   ├── kitty/
│   ├── tmux/
│   ├── zsh/
│   └── Pipxfile
├── macos/
│   ├── Brewfile
│   └── zsh/
└── arch/
    ├── Pacmanfile
    ├── Aurfile
    ├── hypr/
    ├── hyprpaper/
    ├── hypridle/
    ├── hyprlock/
    ├── hyprmoncfg/
    ├── waybar/
    ├── rofi/
    ├── mako/
    └── wallpapers/
```

## Install

Clone the repo, then run either the wrapper or the platform-specific installer:

```bash
git clone https://github.com/minhuy206/dotfiles.git
cd dotfiles
./install.sh
```

macOS:

```bash
./scripts/install-macos.sh
```

Arch Linux:

```bash
./scripts/install-arch.sh
```

Common options:

```bash
./install.sh --help
./install.sh --no-remote-install
./install.sh --skip-git-config
./install.sh --git-name "Your Name" --git-email "you@example.com" --git-default-branch main
```

`--no-remote-install` disables remote installer scripts such as Homebrew bootstrap and yay-bin bootstrap. `--skip-git-config` leaves `~/.gitconfig` untouched.

## What Gets Linked

Shared configs are linked on both macOS and Arch:

- zsh: `~/.zshenv`, `~/.zshrc`, `~/.zimrc`, and `~/.config/zsh/*.zsh`
- tmux: `~/.tmux.conf`
- Neovim: `~/.config/nvim`
- Starship: `~/.config/starship/starship.toml`
- Kitty: `~/.config/kitty/kitty.conf`

macOS additionally links `macos/zsh/25-servbay.zsh` into `~/.config/zsh/`.

Arch additionally links Hyprland, Hyprpaper, Hypridle, Hyprlock, Hyprmoncfg, Waybar, Rofi, Mako, and wallpapers. `~/.config/hypr` remains a real directory so generated files such as `~/.config/hypr/monitors.lua` can coexist with symlinked repo files.

Existing target files, directories, and conflicting symlinks are backed up with a timestamp suffix before replacement.

## Package Manifests

- macOS packages: `macos/Brewfile`
- Arch repo packages: `arch/Pacmanfile`
- Arch AUR packages: `arch/Aurfile`
- Shared pipx tools: `shared/Pipxfile`

Manifest annotations such as `# required` are used by the installer to verify required tools after installation.

## Git Config

The installer updates selected global git keys directly in `~/.gitconfig`: `user.name`, `user.email`, and `init.defaultBranch`. The repo no longer tracks or symlinks a `.gitconfig` file.

## What Changed

- Root `.config/` content was split into `shared/`, `macos/`, and `arch/`.
- `install.sh` became a compatibility wrapper; platform setup now lives in `scripts/install-macos.sh` and `scripts/install-arch.sh`.
- Installer helpers moved to `scripts/lib/`.
- Package manifests moved next to the platform that uses them.
- Hyprpaper wallpaper paths no longer hardcode the repo checkout path.
- Safe symlink handling now backs up conflicting symlinks as well as files/directories.

## Validation

```bash
bash -n install.sh scripts/install-macos.sh scripts/install-arch.sh scripts/lib/*.sh
zsh -n shared/zsh/zshrc
for f in shared/zsh/config/*.zsh macos/zsh/*.zsh; do zsh -n "$f"; done
```
