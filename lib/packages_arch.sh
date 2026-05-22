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
