DOTFILES_OS=""

_detect_linux_distro() {
  local id="" id_like=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-}"
    id_like="${ID_LIKE:-}"
  fi
  case "$id" in
    arch|endeavouros|manjaro|cachyos|garuda|artix)
      printf '%s' arch
      return
      ;;
  esac
  case " $id_like " in
    *" arch "*)
      printf '%s' arch
      return
      ;;
  esac
  printf '%s' unknown
}

detect_os() {
  if [[ -z "$DOTFILES_OS" ]]; then
    case "${OSTYPE:-}" in
      darwin*) DOTFILES_OS=macos ;;
      linux*)  DOTFILES_OS="$(_detect_linux_distro)" ;;
      *)       DOTFILES_OS=unknown ;;
    esac
  fi
  printf '%s' "$DOTFILES_OS"
}
