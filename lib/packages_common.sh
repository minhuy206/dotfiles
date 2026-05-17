# parse_package_file <file> <callback>
# For each non-comment package line, calls: callback <package> [annotation ...]
# Handles Aptfile/Pipxfile format (package [# annotation ...])
# and Brewfile format (brew "package" [# annotation ...] / cask "package" [# annotation ...])
parse_package_file() {
  local file="$1"
  local callback="$2"
  local raw trimmed package rest
  local -a annotations

  [[ -f "$file" ]] || return 0

  while IFS= read -r raw || [[ -n "$raw" ]]; do
    trimmed="${raw#"${raw%%[![:space:]]*}"}"
    [[ -z "$trimmed" ]] && continue
    [[ "$trimmed" == \#* ]] && continue

    # Brewfile: brew "name" or cask "name"
    if [[ "$trimmed" =~ ^(brew|cask)[[:space:]]+'\"'([^\"]*)'\")' ]]; then
      package="${BASH_REMATCH[2]}"
    elif [[ "$trimmed" =~ ^(brew|cask)[[:space:]]+\"([^\"]+)\" ]]; then
      package="${BASH_REMATCH[2]}"
    else
      package="${raw%%#*}"
      package="${package#"${package%%[![:space:]]*}"}"
      package="${package%"${package##*[![:space:]]}"}"
    fi
    [[ -z "$package" ]] && continue

    annotations=()
    if [[ "$raw" == *"#"* ]]; then
      rest="${raw#*#}"
      rest="${rest#"${rest%%[![:space:]]*}"}"
      read -ra annotations <<< "$rest"
    fi

    "$callback" "$package" "${annotations[@]+"${annotations[@]}"}"
  done < "$file"
}

_pipx_install_pkg() {
  local package="$1"
  if installer_tool_present "$package"; then
    log "ok  $package already available"
    return 0
  fi
  log "Installing $package via pipx"
  if pipx install --force "$package"; then
    log "ok  $package installed"
  else
    log "$package pipx install failed."
  fi
}

install_pipx_packages() {
  local pipxfile="$repo_root/Pipxfile"

  [[ -f "$pipxfile" ]] || return 0

  if ! have_command pipx; then
    log "Skipping pipx packages: pipx is not available."
    return 0
  fi

  parse_package_file "$pipxfile" _pipx_install_pkg
}
