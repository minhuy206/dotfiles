# dotfiles

Personal configuration for macOS and Arch Linux, with shared terminal and development tools and an Arch-only Hyprland desktop. The terminal stack uses Rosé Pine; Neovim is configured primarily for SystemVerilog, Tcl/EDA constraints, LaTeX, and Markdown.

## Repository layout

```text
install.sh                     OS-detecting installer entry point
scripts/
  install-macos.sh              Homebrew, pipx, shared configs, macOS overlay
  install-arch.sh               pacman, AUR, pipx, desktop configs and services
  lib/                         Argument parsing, OS detection, packages,
                               tool verification, symlinks, and Git setup
shared/
  zsh/                         Startup files, Zim modules, numbered fragments
  tmux/                        Terminal multiplexer configuration
  kitty/                       Shared theme plus macos.conf and linux.conf
  starship/                    Prompt and color palettes
  nvim/                        Lua configuration and lazy-lock.json
  Pipxfile                     Shared Python CLI tools
macos/
  Brewfile                     Homebrew formulae and applications
  zsh/                         ServBay PATH overlay
arch/
  Pacmanfile                   Official repository packages
  Aurfile                      AUR packages
  hypr/                        Lua entry point and desktop modules
  hyprpaper/ hypridle/ hyprlock/ Wallpaper, idle, and lock configuration
  hyprmoncfg/                   Monitor profiles
  waybar/ rofi/ mako/           Status bar, launcher, and notifications
  wallpapers/                  Wallpaper assets
AGENTS.md / CLAUDE.md           Agent guidance
```

## Installation

Start with an existing macOS or Arch Linux installation and Git available. Review the package manifests and machine-specific settings below before installing.

```bash
git clone https://github.com/minhuy206/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The wrapper detects the OS. Platform installers can also be run directly:

```bash
./scripts/install-macos.sh
./scripts/install-arch.sh
```

### Installer options

| Option | Behavior |
| --- | --- |
| `-h`, `--help` | Print usage without installing anything. |
| `--allow-remote-install` | Allow Homebrew/yay bootstrap; enabled by default. |
| `--no-remote-install` | Disable Homebrew/yay bootstrap. Existing package managers can still download and install packages. |
| `--skip-git-config` | Skip Git prompts and all installer writes to `~/.gitconfig`. |
| `--git-name VALUE` | Set `user.name`. |
| `--git-email VALUE` | Set `user.email`. |
| `--git-default-branch VALUE` | Set `init.defaultBranch`. |

Git flags also accept `--flag=value`. They cannot be combined with `--skip-git-config`.

```bash
./install.sh --no-remote-install --skip-git-config
./install.sh --git-name "Your Name" --git-email "you@example.com" --git-default-branch main
```

`--no-remote-install` is not an offline or dry-run mode. It also does not control later downloads performed by Zim during shell startup or by Neovim plugins.

### What the installers do

- **macOS:** bootstrap Homebrew if needed and allowed, install the Brewfile bundle, install shared pipx tools, link shared and macOS configuration, configure Git, and verify required commands.
- **Arch:** install available Pacmanfile packages, install Aurfile packages through yay (bootstrapping yay-bin if allowed), install pipx tools, and link shared and desktop configuration. Enable Ly and Bluetooth when their commands are available, attempt to enable/start the `hyprmoncfgd` user service, and attempt to change the login shell to zsh.
- Manifest `# required` annotations add command checks at the end of installation; missing required tools cause a nonzero exit. `group:*` annotations are informational. Unavailable pacman packages are reported and skipped before the final verification.

The installer writes only `user.name`, `user.email`, and `init.defaultBranch` through Git configuration commands; it does not create a `.gitconfig` symlink. Interactive runs prompt for unspecified values. Noninteractive runs use existing values or fallbacks (`$USER`, `$USER@localhost`, and `main`), so supply explicit flags or use `--skip-git-config` as appropriate.

### Linked files and backups

| Source | Destination |
| --- | --- |
| `shared/zsh/zshenv`, `zshrc`, `zimrc` | `~/.zshenv`, `~/.zshrc`, `~/.zimrc` |
| `shared/zsh/config/*.zsh` | Individual files in `~/.config/zsh/` |
| `shared/tmux/tmux.conf` | `~/.tmux.conf` |
| `shared/nvim/` | `~/.config/nvim` |
| `shared/starship/starship.toml` | `~/.config/starship/starship.toml` |
| `shared/kitty/{kitty,macos,linux}.conf` | Corresponding files in `~/.config/kitty/` |
| `macos/zsh/25-servbay.zsh` | `~/.config/zsh/25-servbay.zsh` on macOS |
| `arch/hypr/hyprland.lua`, `arch/hypr/modules/` | Corresponding entries in `~/.config/hypr/` on Arch |
| Arch Hyprpaper, Hypridle, Hyprlock configs | Corresponding `.conf` files in `~/.config/hypr/` |
| `arch/hyprmoncfg/`, `waybar/`, `rofi/` | Corresponding directories in `~/.config/` |
| `arch/mako/config` | `~/.config/mako/config` |
| `arch/wallpapers/` | `~/wallpapers` |

Existing files, directories, and conflicting symlinks are renamed to `<target>.YYYYMMDDHHMMSS.bak` before replacement. Correct symlinks are left in place. `~/.config/hypr` remains a real directory so generated `monitors.lua` can coexist with linked files. Keep the checkout at its installed location because symlinks point into it.

After installation, start a new shell and open Neovim to allow its configured downloads to complete. On Arch, select the Hyprland session in Ly after rebooting.

## Package manifests and additional tools

The full package lists live in [macos/Brewfile](macos/Brewfile), [arch/Pacmanfile](arch/Pacmanfile), [arch/Aurfile](arch/Aurfile), and [shared/Pipxfile](shared/Pipxfile).

Shared tools include Neovim, Kitty, tmux, Starship, zoxide, ripgrep, fd, bat, eza, GitHub CLI, and lazygit. The pipx manifest installs `tclint`, which provides the `tclsp` language server. Arch additionally installs the Wayland desktop, audio/network tools, and AUR packages including Prettier and hyprmoncfg.

Some configured integrations need tools installed separately:

- LaTeX distribution, `latexmk`, and `latexindent`; VimTeX selects Skim on macOS and Zathura on Linux, so install the matching viewer.
- `stylua` for Lua formatting; Prettier on macOS for JSON/JSONC/CSS formatting.
- A compiler and the tooling needed to build Tree-sitter parsers; the Arch manifest includes `tree-sitter-cli`.
- NVM and pnpm if used; the shell config references them but the installers do not bootstrap them.
- Zen Browser and Thunderbird for the configured Hyprland shortcuts; neither is listed in the Arch manifests.
- ServBay and the local Cadence Xcelium installation are machine-specific integrations, not installed by this repository.

## Shell and terminal

### zsh

`shared/zsh/zshrc` loads readable numbered `~/.config/zsh/*.zsh` fragments in order:

| Fragment | Purpose |
| --- | --- |
| `00-options` | History and key/input options. |
| `10-zim` | Bootstrap/load Zim; modules are declared in `shared/zsh/zimrc`. |
| `20-path` | Add `~/.local/bin` and pnpm; load an existing NVM installation. |
| `25-servbay` (macOS) | Prefer existing ServBay Python and configured Node directories. |
| `30-aliases` | eza/bat aliases, the `dotfiles` Git helper, and Xcelium alias. |
| `40-tools` | Initialize Starship with this repository's config. |
| `50-tmux` | Attach to or create tmux session `main` in interactive shells outside tmux. |
| `99-zoxide` | Initialize zoxide as `cd`, plus `z` and `zi` helpers. |

Set `DISABLE_AUTO_TMUX=1` before starting a shell to skip automatic tmux attachment. The `dotfiles` helper targets `~/dotfiles`; set `DOTFILES_DIR` before shell startup if the checkout is elsewhere. Tool-specific aliases and initialization are generally guarded by command availability.

### Kitty, tmux, and Starship

- **Kitty:** Rosé Pine main palette, 80% background opacity, JetBrainsMono Nerd Font, copy-on-select, and a bottom tab bar. `include ${KITTY_OS}.conf` selects the font-size override: 12 on macOS, 10 on Linux. Both override files are linked by the installer.
- **tmux:** `Ctrl-a` prefix, mouse support, vi copy mode, numbered windows/panes starting at 1, and Rosé Pine status colors.
- **Starship:** two-line prompt with directory/Git information and contextual language, environment, job, and duration indicators. `rose_pine` is active; alternative palettes remain in the file.

Common tmux bindings, after `Ctrl-a`:

| Key | Action |
| --- | --- |
| `\|` / `-` | Split horizontally / vertically in the current pane's directory. |
| `h j k l` | Move between panes. |
| `H J K L` | Resize panes. |
| `c` | New window in the current directory. |
| `T` | Open a shell popup. |
| `r` | Reload `~/.tmux.conf`. |

## Neovim

Configuration lives in [shared/nvim](shared/nvim). `init.lua` loads options, mappings, and lazy.nvim; plugin specs live in `lua/minhuy/plugins/`, with revisions recorded in `lazy-lock.json`. The current lockfile contains 27 plugins including lazy.nvim and dependencies. The configuration uses modern Neovim APIs; the current local setup was checked with Neovim 0.12.5.

### Features

- Rosé Pine main with transparency, lualine, bufferline, and which-key. The local `monochrome-wave` colorscheme remains available but is not the startup theme.
- Neo-tree opens in the current window when starting without file arguments. Telescope provides file/content/buffer/help search; Outline provides the symbol outline; lazygit opens the Git UI.
- nvim-cmp completes from LSP, VimTeX, paths, and buffers. LuaSnip expands LSP snippets. There is no friendly-snippets collection or separate LuaSnip completion source.
- Native `gc`/`gcc` commenting and nvim-autopairs. Comment.nvim and mini.nvim are not part of the configuration.
- Tree-sitter requests SystemVerilog, Tcl, LaTeX, and BibTeX parsers. Highlighting skips special buffers and files over 1 MB; expression folds are configured but initially disabled.
- Markdown preview uses `selimacerbas/markdown-preview.nvim` and its live-server dependency. VimTeX handles LaTeX compilation/viewing through `latexmk` and the platform PDF viewer.
- Relative line numbers, wrapped/indented display lines, four-space indentation, persistent undo, and cursor-position restoration.

### Language tools

| Files | LSP | Formatting and linting |
| --- | --- | --- |
| TeX, plain TeX, BibTeX | Texlab | `latexindent` for `tex` when available; LSP formatting fallback. |
| Verilog, SystemVerilog | Verible when executable is available | Verible formatter when available; nvim-lint runs Verible on buffer entry/save. |
| Tcl, SDC, UPF, XDC | `tclsp` when available | LSP formatting fallback where supported. |
| JSON, JSONC, CSS | No dedicated LSP configured | Prettier; JSONC is explicitly passed the JSON parser. |
| Lua | No dedicated LSP configured | StyLua when available. |

Mason is configured to install Texlab and Verible. Conform formats on save, with a five-second timeout for TeX/plain TeX and one second otherwise, and enables LSP fallback. Optional executables are checked when their plugin configuration runs; restart Neovim after installing missing tools.

### Main keybindings

Both leader and local leader are **Space**.

| Key | Action |
| --- | --- |
| `Space e` / `Space E` / `Space o` | Toggle Neo-tree / reveal file / toggle tree focus. |
| `Space ff` / `Space fg` | Find files (including hidden files) / live grep. |
| `Space fb` / `Space fh` | Search buffers / help tags. |
| `Space O` | Toggle symbol outline. |
| `Space gg` | Open lazygit. |
| `Space mp` | Start Markdown preview in Markdown buffers. |
| `Tab` / `Shift-Tab` | Next / previous buffer. |
| `Space x` | Close buffer with an unsaved-change prompt. |
| `Space y` / `Space Y` | Copy selection or motion / line to system clipboard. |
| `Space p` (visual) | Paste without replacing the source register. |
| `Space u` | Open `nvim.undotree` in a right-hand split; requires that runtime package. |
| `gc` / `gcc` | Native comment operator / comment line. |
| `Ctrl-Space` / `Enter` (insert) | Open completion / confirm a selected item. |
| `Space Space` | Reload options/mappings and ask lazy.nvim to check plugin-spec changes. |

`:ConfigStatus` reports the active config path and key mappings. Reloading is partial; restart Neovim after changes that require complete plugin reinitialization.

## Arch desktop and machine-specific settings

[arch/hypr/hyprland.lua](arch/hypr/hyprland.lua) uses Hyprland's Lua `hl` API and loads modules for startup, input, appearance, animations, bindings, and window rules. Use a Hyprland build compatible with that configuration format.

- Startup launches Hyprpaper, Waybar, Mako, the polkit agent, and the Hypridle user service.
- Hypridle locks after five minutes and turns displays off after ten minutes.
- Hyprmoncfg profiles cover the author's laptop and LG external monitor. The entry point loads generated `~/.config/hypr/monitors.lua` when present; the tracked `modules/monitors.lua` is not loaded.
- Waybar shows workspaces, time, audio, Bluetooth, network, and battery. Its optional notification widget expects `swaync-client`, while the installed notification daemon is Mako; the widget is gated on command availability.
- Update monitor profile identifiers, wallpaper output names, and Waybar's `wlp0s20f3` network interface for your machine. Review the ServBay paths and `~/EDA/cadence/xcelium/XCELIUM1803.sh` alias on other hosts.

Selected desktop bindings:

| Key | Action |
| --- | --- |
| `Super T` | Kitty. |
| `Super E` / `Super F` | Nemo. |
| `Super B` / `Super M` | Zen Browser / Thunderbird. |
| `Super Space` / `Super Shift Space` | Application launcher / command runner. |
| `Super Q` | Close window. |
| `Super h/j/k/l` | Move focus; add Shift to move the window. |
| `Super 1`–`5` | Switch workspace; add Shift to move the window. |
| `Super S` | Toggle scratchpad. |
| `Print` / `Super Print` | Copy output / region screenshot. |
| `Super Shift Print` | Save region screenshot to `~/Pictures/`. |

## Validation

There is no formal build pipeline. Run syntax checks from the repository root, checking each script separately:

```bash
for f in install.sh scripts/install-*.sh scripts/lib/*.sh; do
  bash -n "$f" || exit 1
done
for f in shared/zsh/zshenv shared/zsh/zshrc shared/zsh/zimrc shared/zsh/config/*.zsh macos/zsh/*.zsh; do
  zsh -n "$f" || exit 1
done
./install.sh --help
./scripts/install-macos.sh --help
./scripts/install-arch.sh --help
git diff --check
```

Test symlink changes against a temporary destination directory, including existing-file backups and repeated runs. A full installer run installs packages and changes user/system configuration even with `--skip-git-config`; use a disposable environment for full installation testing. Desktop behavior requires an Arch/Wayland session to verify.
