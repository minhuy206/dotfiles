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

require_os() {
  local expected="$1"
  local label="$2"
  local actual

  actual="$(detect_os)"
  if [[ "$actual" != "$expected" ]]; then
    log "This installer is for $label, but detected: ${actual:-unknown}."
    exit 1
  fi
}
