git_config_current_value() {
  local key="$1"
  local value=""

  if have_command git && [[ -f "$home_dir/.gitconfig" ]]; then
    value="$(git config --file "$home_dir/.gitconfig" --get "$key" 2>/dev/null || true)"
  fi

  printf '%s' "$value"
}

prompt_with_default() {
  local label="$1"
  local default_value="$2"
  local input=""

  if [[ -n "$default_value" ]]; then
    read -r -p "$label [$default_value]: " input
    if [[ -z "$input" ]]; then
      input="$default_value"
    fi
  else
    read -r -p "$label: " input
  fi

  printf '%s' "$input"
}

ensure_no_newline() {
  local value="$1"
  local label="$2"

  if [[ "$value" == *$'\n'* ]]; then
    log "Invalid $label: value cannot contain newlines."
    exit 1
  fi
}

ensure_valid_git_branch_name() {
  local branch="$1"

  if [[ "$branch" =~ [[:space:]] ]]; then
    log "Invalid git default branch: whitespace is not allowed."
    exit 1
  fi
}

collect_git_config_values() {
  local current_name current_email current_branch

  current_name="$(git_config_current_value user.name)"
  current_email="$(git_config_current_value user.email)"
  current_branch="$(git_config_current_value init.defaultBranch)"

  [[ -z "$git_user_name" ]]     && git_user_name="$current_name"
  [[ -z "$git_user_email" ]]    && git_user_email="$current_email"
  [[ -z "$git_default_branch" ]] && git_default_branch="$current_branch"

  [[ -z "$git_user_name" ]]     && git_user_name="${USER:-}"
  [[ -z "$git_user_email" ]]    && git_user_email="${USER:-user}@localhost"
  [[ -z "$git_default_branch" ]] && git_default_branch="main"

  if is_interactive_shell; then
    log ""
    log "Configure global git identity for ~/.gitconfig"
    [[ "$git_user_name_from_args" -eq 0 ]]     && git_user_name="$(prompt_with_default "Git user.name" "$git_user_name")"
    [[ "$git_user_email_from_args" -eq 0 ]]    && git_user_email="$(prompt_with_default "Git user.email" "$git_user_email")"
    [[ "$git_default_branch_from_args" -eq 0 ]] && git_default_branch="$(prompt_with_default "Git init.defaultBranch" "$git_default_branch")"
  fi

  [[ -z "$git_user_name" ]]     && { log "Git user.name cannot be empty."; exit 1; }
  [[ -z "$git_user_email" ]]    && { log "Git user.email cannot be empty."; exit 1; }
  [[ -z "$git_default_branch" ]] && { log "Git init.defaultBranch cannot be empty."; exit 1; }

  ensure_no_newline "$git_user_name"     "git user.name"
  ensure_no_newline "$git_user_email"    "git user.email"
  ensure_no_newline "$git_default_branch" "git init.defaultBranch"
  ensure_valid_git_branch_name "$git_default_branch"
}

update_gitconfig() {
  local target="$home_dir/.gitconfig"

  if ! have_command git; then
    log "Skipping gitconfig update: git not installed."
    return 0
  fi

  if [[ -L "$target" ]]; then
    log "warn $target is a symlink; updating in place via git config"
  fi

  git config --global user.name "$git_user_name"
  git config --global user.email "$git_user_email"
  git config --global init.defaultBranch "$git_default_branch"
  log "upd $target (user.name, user.email, init.defaultBranch)"
}
