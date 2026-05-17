log() {
  printf '%s\n' "$*"
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

is_interactive_shell() {
  [[ -t 0 && -t 1 ]]
}

sudo_if_needed() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  elif have_command sudo; then
    sudo "$@"
  else
    log "This command needs root privileges, and sudo is not installed."
    log "Rerun this installer as root or install sudo first."
    exit 1
  fi
}

ensure_local_bin_dir() {
  mkdir -p "$home_dir/.local/bin"
  case ":${PATH}:" in
    *":$home_dir/.local/bin:"*) ;;
    *) export PATH="$home_dir/.local/bin:$PATH" ;;
  esac
}
