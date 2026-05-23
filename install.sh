#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
home_dir="${HOME}"

for _lib in \
  "$repo_root/lib/log.sh" \
  "$repo_root/lib/os.sh" \
  "$repo_root/lib/args.sh" \
  "$repo_root/lib/packages_common.sh" \
  "$repo_root/lib/tools_registry.sh" \
  "$repo_root/lib/git_config.sh" \
  "$repo_root/lib/packages_macos.sh" \
  "$repo_root/lib/packages_arch.sh" \
  "$repo_root/lib/links.sh"; do
  source "$_lib"
done
unset _lib

install_packages() {
  local os
  os="$(detect_os)"

  case "$os" in
    macos)
      install_homebrew_if_missing
      install_brew_bundle
      ;;
    arch)
      log "Arch Linux detected: pacman for repo packages, yay for AUR."
      install_pacman_packages
      install_aur_packages
      enable_ly
      enable_bluetooth
      ;;
    *)
      log "Unsupported OS: ${OSTYPE:-unknown}"
      exit 1
      ;;
  esac
}

main() {
  parse_args "$@"
  init_required_tools
  install_packages
  install_pipx_packages

  link_dotfiles

  if [[ "$skip_git_config" -eq 1 ]]; then
    log "Skipping ~/.gitconfig setup (--skip-git-config)."
  else
    collect_git_config_values
    update_gitconfig
  fi

  log ""
  log "Installed dotfiles from: $repo_root"
  log "Next steps:"
  log "  1. Select FiraCode Nerd Font in your terminal settings."
  log "  2. Start a new shell or run: exec zsh"
  log "  3. Open Neovim — Mason will auto-install texlab on first launch."
  local _os
  _os="$(detect_os)"
  if [[ "$_os" == arch ]]; then
    set_default_login_shell || true
    log "  3. If zsh is still not your login shell, run: chsh -s \"$(command -v zsh)\""
    log "  4. If Nerd Font glyphs are missing, install FiraCode Nerd Font manually."
    log "  5. Reboot — ly will start automatically and launch Hyprland."
  fi

  verify_required_tools
}

main "$@"
