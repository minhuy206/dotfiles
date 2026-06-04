#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
home_dir="${HOME}"
installer_name="./scripts/install-macos.sh"

source "$repo_root/scripts/lib/load.sh"

main() {
  parse_args "$@"
  require_os macos "macOS"

  init_required_tools
  install_homebrew_if_missing
  install_brew_bundle
  install_pipx_packages

  link_shared_configs
  link_macos_configs
  configure_git_if_enabled

  log_shared_next_steps
  verify_required_tools
}

main "$@"
