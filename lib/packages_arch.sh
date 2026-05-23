# Module-level arrays used by _pacman_classify_pkg callback
_PACMAN_PACKAGES=()
_PACMAN_SKIPPED=()

_pacman_classify_pkg() {
  local package="$1"
  if pacman -Si "$package" >/dev/null 2>&1; then
    _PACMAN_PACKAGES+=("$package")
  else
    _PACMAN_SKIPPED+=("$package")
  fi
}

install_pacman_packages() {
  local pacmanfile="$repo_root/Pacmanfile"
  _PACMAN_PACKAGES=()
  _PACMAN_SKIPPED=()

  if [[ ! -f "$pacmanfile" ]]; then
    log "Missing Pacmanfile: $pacmanfile"
    exit 1
  fi

  if ! have_command pacman; then
    log "This Arch installer requires pacman."
    exit 1
  fi

  log "Synchronizing pacman package databases (pacman -Sy)"
  sudo_if_needed pacman -Sy --noconfirm

  parse_package_file "$pacmanfile" _pacman_classify_pkg

  if ((${#_PACMAN_PACKAGES[@]})); then
    log "Installing pacman packages"
    sudo_if_needed pacman -S --needed --noconfirm "${_PACMAN_PACKAGES[@]}"
  fi
  ((${#_PACMAN_SKIPPED[@]})) && log "Skipped packages unavailable in current pacman repos: ${_PACMAN_SKIPPED[*]}"
}

# ── AUR via yay ────────────────────────────────────────────────────────────

_bootstrap_yay() {
  have_command yay && return 0

  ensure_remote_install_allowed "yay" || return 1

  log "Installing base-devel and git prerequisites for yay bootstrap"
  sudo_if_needed pacman -S --needed --noconfirm base-devel git

  local tmpdir
  tmpdir="$(mktemp -d)" || {
    log "Failed to create temp dir for yay bootstrap"
    return 1
  }

  log "Cloning yay-bin from AUR into $tmpdir"
  if ! git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"; then
    log "Failed to clone yay-bin from AUR"
    rm -rf "$tmpdir"
    return 1
  fi

  log "Building and installing yay-bin (makepkg -si)"
  if ! (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm); then
    log "yay-bin build failed"
    rm -rf "$tmpdir"
    return 1
  fi

  rm -rf "$tmpdir"
  have_command yay
}

_AUR_PACKAGES=()

_aur_collect_pkg() {
  _AUR_PACKAGES+=("$1")
}

enable_ly() {
  if ! have_command ly; then
    log "ly not found after install; skipping systemd enable"
    return 0
  fi
  log "Enabling ly display manager (systemctl enable ly)"
  sudo_if_needed systemctl enable ly
}

enable_bluetooth() {
  if ! have_command bluetoothctl; then
    log "bluetoothctl not found after install; skipping systemd enable for bluetooth"
    return 0
  fi
  log "Enabling bluetooth service (systemctl enable bluetooth)"
  sudo_if_needed systemctl enable bluetooth
}

install_aur_packages() {
  local aurfile="$repo_root/Aurfile"
  _AUR_PACKAGES=()

  [[ -f "$aurfile" ]] || return 0

  parse_package_file "$aurfile" _aur_collect_pkg

  if ((${#_AUR_PACKAGES[@]} == 0)); then
    return 0
  fi

  if ! _bootstrap_yay; then
    log "Skipping AUR packages (yay not available): ${_AUR_PACKAGES[*]}"
    return 0
  fi

  log "Installing AUR packages via yay: ${_AUR_PACKAGES[*]}"
  yay -S --needed --noconfirm "${_AUR_PACKAGES[@]}"
}

# ── Login shell ──────────────────────────────────────────────────────────────

set_default_login_shell() {
  local current_login_shell zsh_path

  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    log "Skipping login shell update: zsh is not installed."
    return 1
  fi

  current_login_shell="$(getent passwd "${USER:-}" 2>/dev/null | awk -F: '{print $7}')"
  if [[ -n "$current_login_shell" && "$current_login_shell" == "$zsh_path" ]]; then
    log "ok  login shell already set to zsh ($zsh_path)"
    return 0
  fi

  if ! have_command chsh; then
    log "Skipping login shell update: chsh is not available."
    return 1
  fi

  if ! grep -Fxq "$zsh_path" /etc/shells 2>/dev/null; then
    log "Skipping login shell update: $zsh_path is not listed in /etc/shells."
    log "Add it to /etc/shells, then run: chsh -s \"$zsh_path\""
    return 1
  fi

  log "Setting zsh as default login shell (you may be prompted for your password)"
  if chsh -s "$zsh_path"; then
    log "ok  login shell updated to zsh ($zsh_path)"
    return 0
  fi

  log "Could not update login shell automatically."
  log "Run manually: chsh -s \"$zsh_path\""
  return 1
}
