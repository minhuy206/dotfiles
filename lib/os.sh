DOTFILES_OS=""

detect_os() {
  if [[ -z "$DOTFILES_OS" ]]; then
    case "${OSTYPE:-}" in
      darwin*) DOTFILES_OS=macos ;;
      linux*)  DOTFILES_OS=linux ;;
      *)       DOTFILES_OS=unknown ;;
    esac
  fi
  printf '%s' "$DOTFILES_OS"
}
