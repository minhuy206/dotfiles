allow_remote_install=1
skip_git_config=0
git_user_name=""
git_user_email=""
git_default_branch=""
git_user_name_from_args=0
git_user_email_from_args=0
git_default_branch_from_args=0

print_usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  --allow-remote-install   Allow remote script installers (default)
  --no-remote-install      Disable remote script installers
  --skip-git-config        Skip git identity/default branch prompts and do not write ~/.gitconfig
  --git-name VALUE         Set git user.name in ~/.gitconfig
  --git-email VALUE        Set git user.email in ~/.gitconfig
  --git-default-branch VAL Set git init.defaultBranch in ~/.gitconfig
  -h, --help               Show this help message
EOF
}

# _consume_git_flag <flag> <varname> <value>
# Validates non-empty, assigns to named variable, sets *_from_args=1
_consume_git_flag() {
  local flag="$1" varname="$2" value="$3"
  if [[ -z "$value" ]]; then
    log "Missing value for $flag"
    exit 1
  fi
  printf -v "$varname" '%s' "$value"
  printf -v "${varname}_from_args" '%s' 1
}

ensure_remote_install_allowed() {
  local tool="$1"
  if [[ "$allow_remote_install" -eq 1 ]]; then
    return 0
  fi
  log "Skipping $tool remote installer: disabled by --no-remote-install."
  log "Use --allow-remote-install to enable remote script execution."
  return 1
}

parse_args() {
  # Table of git flags: "<flag>:<varname>"
  local _git_flags=(
    "--git-name:git_user_name"
    "--git-email:git_user_email"
    "--git-default-branch:git_default_branch"
  )

  while (($#)); do
    local matched=0
    local entry flag varname

    for entry in "${_git_flags[@]}"; do
      flag="${entry%%:*}"
      varname="${entry#*:}"
      if [[ "$1" == "$flag" ]]; then
        shift
        _consume_git_flag "$flag" "$varname" "${1:-}"
        matched=1
        break
      elif [[ "$1" == "$flag="* ]]; then
        _consume_git_flag "$flag" "$varname" "${1#*=}"
        matched=1
        break
      fi
    done

    if [[ "$matched" -eq 1 ]]; then
      shift
      continue
    fi

    case "$1" in
      --allow-remote-install)
        allow_remote_install=1
        ;;
      --no-remote-install)
        allow_remote_install=0
        ;;
      --skip-git-config)
        skip_git_config=1
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      *)
        log "Unknown option: $1"
        print_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ "$skip_git_config" -eq 1 ]] && \
     [[ "$git_user_name_from_args" -eq 1 || \
        "$git_user_email_from_args" -eq 1 || \
        "$git_default_branch_from_args" -eq 1 ]]; then
    log "Cannot combine --skip-git-config with --git-name, --git-email, or --git-default-branch."
    exit 1
  fi
}
