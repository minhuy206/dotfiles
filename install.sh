#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
home_dir="${HOME}"

log() {
  printf '%s\n' "$*"
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

setup_homebrew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew_if_missing() {
  setup_homebrew_shellenv

  if have_command brew; then
    log "ok  homebrew:$(brew --prefix)"
    return 0
  fi

  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  setup_homebrew_shellenv

  if ! have_command brew; then
    log "Homebrew install finished, but brew is not available in PATH."
    log "Add Homebrew to your shell profile, then rerun this installer."
    exit 1
  fi
}

install_brew_bundle() {
  local brewfile="$repo_root/Brewfile"

  if [[ ! -f "$brewfile" ]]; then
    log "Missing Brewfile: $brewfile"
    exit 1
  fi

  log "Installing Homebrew bundle"
  brew bundle --file "$brewfile"
}

backup_path() {
  local target="$1"
  printf '%s.%s.bak' "$target" "$(date +%Y%m%d%H%M%S)"
}

link_file() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log "ok  $target -> $source"
      return 0
    fi
    rm "$target"
  elif [[ -e "$target" ]]; then
    local backup
    backup="$(backup_path "$target")"
    mv "$target" "$backup"
    log "bak $target -> $backup"
  fi

  ln -s "$source" "$target"
  log "ln  $target -> $source"
}

main() {
  if [[ "${OSTYPE:-}" != darwin* ]]; then
    log "This installer is intended for macOS."
  fi

  install_homebrew_if_missing
  install_brew_bundle

  link_file "$repo_root/.zshrc" "$home_dir/.zshrc"
  link_file "$repo_root/.zimrc" "$home_dir/.zimrc"
  link_file "$repo_root/.gitconfig" "$home_dir/.gitconfig"
  link_file "$repo_root/.tmux.conf" "$home_dir/.tmux.conf"
  link_file "$repo_root/.config/starship/starship.toml" "$home_dir/.config/starship/starship.toml"
  link_file "$repo_root/.config/kitty/kitty.conf" "$home_dir/.config/kitty/kitty.conf"

  log ""
  log "Installed dotfiles from: $repo_root"
  log "Next steps:"
  log "  1. Select FiraCode Nerd Font in your terminal settings."
  log "  2. Start a new shell or run: exec zsh"
}

main "$@"
