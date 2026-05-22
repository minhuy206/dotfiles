LINUX_REPO_PACKAGES=()
linux_repo_sources_changed=0

queue_linux_repo_package() {
  _array_add_unique LINUX_REPO_PACKAGES "$1"
}

# ── Repo-based installers (gh, eza) ─────────────────────────────────────────

_install_gh_linux_repo() {
  local arch

  if ! have_command curl || ! have_command dpkg; then
    log "Skipping gh script install: curl or dpkg not available."
    return 1
  fi

  arch="$(dpkg --print-architecture)"
  if [[ "$arch" != "amd64" && "$arch" != "arm64" ]]; then
    log "Skipping gh script install: unsupported architecture $arch"
    return 1
  fi

  log "Installing gh via official GitHub CLI apt repository"
  sudo_if_needed mkdir -p /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo_if_needed tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo_if_needed chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "$arch" \
    | sudo_if_needed tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  linux_repo_sources_changed=1
  queue_linux_repo_package "gh"
}

_install_eza_linux_repo() {
  if ! have_command curl; then
    log "Skipping eza script install: curl not available."
    return 1
  fi

  if ! have_command gpg; then
    log "Installing gpg prerequisite for eza repository setup"
    sudo_if_needed apt-get install -y gpg
  fi

  log "Installing eza via eza apt repository"
  sudo_if_needed mkdir -p /etc/apt/keyrings
  curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo_if_needed gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  printf 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main\n' \
    | sudo_if_needed tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo_if_needed chmod 644 /etc/apt/keyrings/gierens.gpg
  linux_repo_sources_changed=1
  queue_linux_repo_package "eza"
}

# ── Script-based installers (starship, zoxide, tailscale, kitty) ────────────

# _run_script_install <name> <url> [sh_args...]
# Replaces @BIN@ in any argument with $home_dir/.local/bin (and ensures the dir exists).
_run_script_install() {
  local name="$1" url="$2"
  shift 2
  local -a sh_cmd=("$@")
  local needs_bin=0 i

  have_command "$name" && return 0
  have_command curl || { log "Skipping $name script install: curl not available."; return 1; }
  ensure_remote_install_allowed "$name" || return 1

  for i in "${!sh_cmd[@]}"; do
    if [[ "${sh_cmd[$i]}" == *"@BIN@"* ]]; then
      needs_bin=1
      sh_cmd[$i]="${sh_cmd[$i]//@BIN@/$home_dir/.local/bin}"
    fi
  done
  [[ "$needs_bin" -eq 1 ]] && ensure_local_bin_dir

  log "Installing $name via official installer script"
  curl -fsSL "$url" | "${sh_cmd[@]}"
}

_kitty_post_install() {
  if [[ -x "$home_dir/.local/kitty.app/bin/kitty" ]]; then
    ln -sf "$home_dir/.local/kitty.app/bin/kitty"  "$home_dir/.local/bin/kitty"
    ln -sf "$home_dir/.local/kitty.app/bin/kitten" "$home_dir/.local/bin/kitten"

    mkdir -p "$home_dir/.local/share/applications"
    cp "$home_dir/.local/kitty.app/share/applications/kitty.desktop"      "$home_dir/.local/share/applications/"
    cp "$home_dir/.local/kitty.app/share/applications/kitty-open.desktop" "$home_dir/.local/share/applications/"

    sed -i "s|Icon=kitty|Icon=$home_dir/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" \
      "$home_dir/.local/share/applications/kitty"*.desktop
    sed -i "s|Exec=kitty|Exec=$home_dir/.local/kitty.app/bin/kitty|g" \
      "$home_dir/.local/share/applications/kitty"*.desktop

    mkdir -p "$home_dir/.config"
    printf 'kitty.desktop\n' > "$home_dir/.config/xdg-terminals.list"
  fi
}

# ── Queue drain ─────────────────────────────────────────────────────────────

install_queued_linux_repo_packages() {
  ((${#LINUX_REPO_PACKAGES[@]} == 0)) && return 0

  if [[ "$linux_repo_sources_changed" -eq 1 ]]; then
    log "Refreshing apt metadata for newly added repositories"
    sudo_if_needed apt-get update
  fi

  log "Installing packages from added apt repositories: ${LINUX_REPO_PACKAGES[*]}"
  sudo_if_needed apt-get install -y "${LINUX_REPO_PACKAGES[@]}"
}

# ── Main Linux script-tool dispatch ─────────────────────────────────────────

install_linux_script_tools_if_missing() {
  local pkg
  local failed=()

  for pkg in "${SCRIPT_FALLBACK_PACKAGES[@]+"${SCRIPT_FALLBACK_PACKAGES[@]}"}"; do
    have_command "$pkg" && continue
    case "$pkg" in
      gh)
        _install_gh_linux_repo || failed+=("$pkg")
        ;;
      eza)
        _install_eza_linux_repo || failed+=("$pkg")
        ;;
      starship)
        _run_script_install starship https://starship.rs/install.sh \
          sh -s -- -y -b @BIN@ || failed+=("$pkg")
        ;;
      zoxide)
        _run_script_install zoxide \
          https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
          sh -s -- --bin-dir @BIN@ || failed+=("$pkg")
        ;;
      tailscale)
        _run_script_install tailscale https://tailscale.com/install.sh \
          sh || failed+=("$pkg")
        ;;
      kitty)
        _run_script_install kitty https://sw.kovidgoyal.net/kitty/installer.sh \
          sh /dev/stdin && _kitty_post_install || failed+=("$pkg")
        ;;
    esac
  done

  install_queued_linux_repo_packages || {
    local p
    for p in "${LINUX_REPO_PACKAGES[@]+"${LINUX_REPO_PACKAGES[@]}"}"; do
      failed+=("$p")
    done
  }

  if ((${#failed[@]})); then
    log "Script install fallback failed for: ${failed[*]}"
    log "Install them manually or adjust apt sources and rerun installer."
  fi
}

# ── apt package install ──────────────────────────────────────────────────────

# Module-level arrays used by _apt_classify_pkg callback (callbacks can't access local vars)
_APT_PACKAGES=()
_APT_SKIPPED=()
_APT_SCRIPT_PRIORITY=()

_apt_classify_pkg() {
  local package="$1"
  local pkg
  for pkg in "${SCRIPT_FALLBACK_PACKAGES[@]+"${SCRIPT_FALLBACK_PACKAGES[@]}"}"; do
    if [[ "$pkg" == "$package" ]]; then
      _APT_SCRIPT_PRIORITY+=("$package")
      return
    fi
  done
  if apt-cache show "$package" >/dev/null 2>&1; then
    _APT_PACKAGES+=("$package")
  else
    _APT_SKIPPED+=("$package")
  fi
}

install_apt_packages() {
  local aptfile="$repo_root/Aptfile"
  _APT_PACKAGES=()
  _APT_SKIPPED=()
  _APT_SCRIPT_PRIORITY=()

  if [[ ! -f "$aptfile" ]]; then
    log "Missing Aptfile: $aptfile"
    exit 1
  fi

  if ! have_command apt-get || ! have_command apt-cache; then
    log "This Linux installer requires apt-get and apt-cache."
    exit 1
  fi

  log "Updating apt package metadata"
  sudo_if_needed apt-get update

  parse_package_file "$aptfile" _apt_classify_pkg

  if ((${#_APT_PACKAGES[@]})); then
    log "Installing apt packages"
    sudo_if_needed apt-get install -y "${_APT_PACKAGES[@]}"
  fi
  ((${#_APT_SKIPPED[@]}))         && log "Skipped packages unavailable in current apt sources: ${_APT_SKIPPED[*]}"
  ((${#_APT_SCRIPT_PRIORITY[@]})) && log "Skipped apt for script-priority packages: ${_APT_SCRIPT_PRIORITY[*]}"
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
