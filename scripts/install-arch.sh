#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
home_dir="${HOME}"
installer_name="./scripts/install-arch.sh"

source "$repo_root/scripts/lib/load.sh"

main() {
  parse_args "$@"
  require_os arch "Arch Linux"

  init_required_tools
  log "Arch Linux detected: pacman for repo packages, yay for AUR."
  install_pacman_packages
  install_aur_packages
  install_pipx_packages

  link_shared_configs
  link_arch_configs
  enable_ly
  enable_bluetooth
  enable_hyprmoncfgd || true
  configure_git_if_enabled

  log_shared_next_steps
  set_default_login_shell || true
  log "  4. If zsh is still not your login shell, run: chsh -s \"$(command -v zsh)\""
  log "  5. If Nerd Font glyphs are missing, install JetBrainsMono Nerd Font manually."
  log "  6. Reboot; ly will start automatically and launch Hyprland."

  verify_required_tools
}

main "$@"
