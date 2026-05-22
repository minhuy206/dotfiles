REQUIRED_TOOLS=()
SCRIPT_FALLBACK_PACKAGES=()

_array_add_unique() {
  local arr_name="$1" val="$2"
  local -a tmp item
  # Indirect array expansion — compatible with bash 3.2+
  eval "tmp=(\"\${${arr_name}[@]+\${${arr_name}[@]}}\")"
  for item in "${tmp[@]+"${tmp[@]}"}"; do
    [[ "$item" == "$val" ]] && return 0
  done
  eval "${arr_name}+=($(printf '%q' "$val"))"
}

# Maps apt/Brewfile package names to canonical binary names
_canonical_tool() {
  case "$1" in
    neovim)      printf '%s' nvim ;;
    batcat)      printf '%s' bat ;;
    fd-find)     printf '%s' fd ;;
    github-cli)  printf '%s' gh ;;
    python-pipx) printf '%s' pipx ;;
    *)           printf '%s' "$1" ;;
  esac
}

# Returns 0 if the tool (canonical name) is present on $PATH
installer_tool_present() {
  local tool="$1"
  case "$tool" in
    nvim)   have_command nvim || have_command neovim ;;
    bat)    have_command bat  || have_command batcat ;;
    tclint) have_command tclint || have_command tclsp ;;
    fd)     have_command fd   || have_command fdfind ;;
    *)      have_command "$tool" ;;
  esac
}

# Callback for parse_package_file: register required/script-fallback tools
_register_tool_callback() {
  local package="$1"
  shift
  local canonical ann
  canonical="$(_canonical_tool "$package")"
  for ann in "$@"; do
    case "${ann}" in
      [Rr]equired)        _array_add_unique REQUIRED_TOOLS "$canonical" ;;
      [Ss]cript-fallback) _array_add_unique SCRIPT_FALLBACK_PACKAGES "$package" ;;
    esac
  done
}

init_required_tools() {
  REQUIRED_TOOLS=()
  SCRIPT_FALLBACK_PACKAGES=()

  # Core tools — always required regardless of manifest
  _array_add_unique REQUIRED_TOOLS zsh
  _array_add_unique REQUIRED_TOOLS git
  _array_add_unique REQUIRED_TOOLS tmux
  _array_add_unique REQUIRED_TOOLS nvim

  local os
  os="$(detect_os)"
  case "$os" in
    macos)  parse_package_file "$repo_root/Brewfile"   _register_tool_callback ;;
    arch)   parse_package_file "$repo_root/Pacmanfile" _register_tool_callback ;;
    *)      parse_package_file "$repo_root/Aptfile"    _register_tool_callback ;;
  esac
  parse_package_file "$repo_root/Pipxfile" _register_tool_callback
}

verify_required_tools() {
  local missing=()
  local tool

  for tool in "${REQUIRED_TOOLS[@]+"${REQUIRED_TOOLS[@]}"}"; do
    if installer_tool_present "$tool"; then
      log "req ok $tool"
    else
      missing+=("$tool")
    fi
  done

  if ((${#missing[@]})); then
    log "Required tools missing after install: ${missing[*]}"
    exit 1
  fi
}
