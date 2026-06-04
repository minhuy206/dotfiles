#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$repo_root/scripts/lib/log.sh"
source "$repo_root/scripts/lib/os.sh"

print_wrapper_usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Delegates to the platform-specific installer for the detected OS:
  macOS:      ./scripts/install-macos.sh
  Arch Linux: ./scripts/install-arch.sh

Run a platform installer with --help to see supported options.
EOF
}

main() {
  local os
  os="$(detect_os)"

  case "$os" in
    macos)
      exec "$repo_root/scripts/install-macos.sh" "$@"
      ;;
    arch)
      exec "$repo_root/scripts/install-arch.sh" "$@"
      ;;
    *)
      if (($# > 0)) && [[ "$1" == "-h" || "$1" == "--help" ]]; then
        print_wrapper_usage
        exit 0
      fi
      log "Unsupported OS: ${OSTYPE:-unknown}"
      print_wrapper_usage
      exit 1
      ;;
  esac
}

main "$@"
