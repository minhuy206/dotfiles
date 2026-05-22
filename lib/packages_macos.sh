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

  ensure_remote_install_allowed "Homebrew" || exit 1
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
