#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
home_dir="${HOME}"
allow_remote_install=1
git_user_name=""
git_user_email=""
git_default_branch=""
git_user_name_from_args=0
git_user_email_from_args=0
git_default_branch_from_args=0
linux_repo_sources_changed=0
LINUX_REPO_PACKAGES=()

log() {
  printf '%s\n' "$*"
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

SCRIPT_PRIORITY_PACKAGES=(gh eza starship zoxide tailscale kitty)

is_script_priority_package() {
  local package="$1"
  local candidate

  for candidate in "${SCRIPT_PRIORITY_PACKAGES[@]}"; do
    if [[ "$candidate" == "$package" ]]; then
      return 0
    fi
  done

  return 1
}

has_linux_repo_package() {
  local package="$1"
  local existing

  for existing in "${LINUX_REPO_PACKAGES[@]}"; do
    if [[ "$existing" == "$package" ]]; then
      return 0
    fi
  done

  return 1
}

queue_linux_repo_package() {
  local package="$1"

  if has_linux_repo_package "$package"; then
    return 0
  fi

  LINUX_REPO_PACKAGES+=("$package")
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

print_usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  --allow-remote-install   Allow remote script installers (default)
  --no-remote-install      Disable remote script installers
  --git-name VALUE         Set git user.name in ~/.gitconfig
  --git-email VALUE        Set git user.email in ~/.gitconfig
  --git-default-branch VAL Set git init.defaultBranch in ~/.gitconfig
  -h, --help               Show this help message
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      --allow-remote-install)
        allow_remote_install=1
        ;;
      --no-remote-install)
        allow_remote_install=0
        ;;
      --git-name)
        shift
        if [[ -z "${1:-}" ]]; then
          log "Missing value for --git-name"
          exit 1
        fi
        git_user_name="$1"
        git_user_name_from_args=1
        ;;
      --git-name=*)
        git_user_name="${1#*=}"
        if [[ -z "$git_user_name" ]]; then
          log "Missing value for --git-name"
          exit 1
        fi
        git_user_name_from_args=1
        ;;
      --git-email)
        shift
        if [[ -z "${1:-}" ]]; then
          log "Missing value for --git-email"
          exit 1
        fi
        git_user_email="$1"
        git_user_email_from_args=1
        ;;
      --git-email=*)
        git_user_email="${1#*=}"
        if [[ -z "$git_user_email" ]]; then
          log "Missing value for --git-email"
          exit 1
        fi
        git_user_email_from_args=1
        ;;
      --git-default-branch)
        shift
        if [[ -z "${1:-}" ]]; then
          log "Missing value for --git-default-branch"
          exit 1
        fi
        git_default_branch="$1"
        git_default_branch_from_args=1
        ;;
      --git-default-branch=*)
        git_default_branch="${1#*=}"
        if [[ -z "$git_default_branch" ]]; then
          log "Missing value for --git-default-branch"
          exit 1
        fi
        git_default_branch_from_args=1
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
}

is_interactive_shell() {
  [[ -t 0 && -t 1 ]]
}

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
  local current_name
  local current_email
  local current_branch

  current_name="$(git_config_current_value user.name)"
  current_email="$(git_config_current_value user.email)"
  current_branch="$(git_config_current_value init.defaultBranch)"

  if [[ -z "$git_user_name" ]]; then
    git_user_name="$current_name"
  fi
  if [[ -z "$git_user_email" ]]; then
    git_user_email="$current_email"
  fi
  if [[ -z "$git_default_branch" ]]; then
    git_default_branch="$current_branch"
  fi

  if [[ -z "$git_user_name" ]]; then
    git_user_name="${USER:-}"
  fi
  if [[ -z "$git_user_email" ]]; then
    git_user_email="${USER:-user}@localhost"
  fi
  if [[ -z "$git_default_branch" ]]; then
    git_default_branch="main"
  fi

  if is_interactive_shell; then
    log ""
    log "Configure global git identity for ~/.gitconfig"
    if [[ "$git_user_name_from_args" -eq 0 ]]; then
      git_user_name="$(prompt_with_default "Git user.name" "$git_user_name")"
    fi
    if [[ "$git_user_email_from_args" -eq 0 ]]; then
      git_user_email="$(prompt_with_default "Git user.email" "$git_user_email")"
    fi
    if [[ "$git_default_branch_from_args" -eq 0 ]]; then
      git_default_branch="$(prompt_with_default "Git init.defaultBranch" "$git_default_branch")"
    fi
  fi

  if [[ -z "$git_user_name" ]]; then
    log "Git user.name cannot be empty."
    exit 1
  fi
  if [[ -z "$git_user_email" ]]; then
    log "Git user.email cannot be empty."
    exit 1
  fi
  if [[ -z "$git_default_branch" ]]; then
    log "Git init.defaultBranch cannot be empty."
    exit 1
  fi

  ensure_no_newline "$git_user_name" "git user.name"
  ensure_no_newline "$git_user_email" "git user.email"
  ensure_no_newline "$git_default_branch" "git init.defaultBranch"
  ensure_valid_git_branch_name "$git_default_branch"
}

setup_homebrew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew_if_missing() {
  setup_homebrew_shellenv

  if have_command brew; then
    log "ok  homebrew:$(brew --prefix)"
    return 0
  fi

  ensure_remote_install_allowed "Homebrew" || exit 1
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  setup_homebrew_shellenv

  if ! have_command brew; then
    log "Homebrew install finished, but brew is not available in PATH."
    log "Add Homebrew to your shell profile, then rerun this installer."
    exit 1
  fi
}

install_brew_bundle() {
  local brewfile="$repo_root/Brewfile"

  if [[ ! -f "$brewfile" ]]; then
    log "Missing Brewfile: $brewfile"
    exit 1
  fi

  log "Installing Homebrew bundle"
  brew bundle --file "$brewfile"
}

detect_os() {
  case "${OSTYPE:-}" in
    darwin*) printf 'macos' ;;
    linux*) printf 'linux' ;;
    *) printf 'unknown' ;;
  esac
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

install_apt_packages() {
  local aptfile="$repo_root/Aptfile"
  local package
  local packages=()
  local skipped=()
  local script_priority=()

  if [[ ! -f "$aptfile" ]]; then
    log "Missing Aptfile: $aptfile"
    exit 1
  fi

  if ! have_command apt-get || ! have_command apt-cache; then
    log "This Linux installer requires apt-get and apt-cache."
    exit 1
  fi

  log "Updating apt package metadata"
  sudo_if_needed apt-get update

  while IFS= read -r package || [[ -n "$package" ]]; do
    package="${package%%#*}"
    package="${package#"${package%%[![:space:]]*}"}"
    package="${package%"${package##*[![:space:]]}"}"

    if [[ -z "$package" ]]; then
      continue
    fi

    if is_script_priority_package "$package"; then
      script_priority+=("$package")
      continue
    fi

    if apt-cache show "$package" >/dev/null 2>&1; then
      packages+=("$package")
    else
      skipped+=("$package")
    fi
  done < "$aptfile"

  if ((${#packages[@]})); then
    log "Installing apt packages"
    sudo_if_needed apt-get install -y "${packages[@]}"
  fi

  if ((${#skipped[@]})); then
    log "Skipped packages unavailable in current apt sources: ${skipped[*]}"
  fi

  if ((${#script_priority[@]})); then
    log "Skipped apt for script-priority packages: ${script_priority[*]}"
  fi
}

ensure_local_bin_dir() {
  mkdir -p "$home_dir/.local/bin"
}

install_gh_linux_script() {
  local arch

  if have_command gh; then
    return 0
  fi

  if ! have_command curl || ! have_command dpkg; then
    log "Skipping gh script install: curl or dpkg not available."
    return 1
  fi

  arch="$(dpkg --print-architecture)"
  if [[ "$arch" != "amd64" && "$arch" != "arm64" ]]; then
    log "Skipping gh script install: unsupported architecture $arch"
    return 1
  fi

  log "Installing gh via official GitHub CLI apt repository"
  sudo_if_needed mkdir -p /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo_if_needed tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo_if_needed chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "$arch" \
    | sudo_if_needed tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  linux_repo_sources_changed=1
  queue_linux_repo_package "gh"
}

install_eza_linux_script() {
  if have_command eza; then
    return 0
  fi

  if ! have_command curl; then
    log "Skipping eza script install: curl not available."
    return 1
  fi

  if ! have_command gpg; then
    log "Installing gpg prerequisite for eza repository setup"
    sudo_if_needed apt-get install -y gpg
  fi

  log "Installing eza via eza apt repository"
  sudo_if_needed mkdir -p /etc/apt/keyrings
  curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo_if_needed gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  printf 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main\n' \
    | sudo_if_needed tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo_if_needed chmod 644 /etc/apt/keyrings/gierens.gpg
  linux_repo_sources_changed=1
  queue_linux_repo_package "eza"
}

install_starship_linux_script() {
  if have_command starship; then
    return 0
  fi

  if ! have_command curl; then
    log "Skipping starship script install: curl not available."
    return 1
  fi

  ensure_remote_install_allowed "starship" || return 1

  ensure_local_bin_dir
  log "Installing starship via official installer script"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$home_dir/.local/bin"
}

install_zoxide_linux_script() {
  if have_command zoxide; then
    return 0
  fi

  if ! have_command curl; then
    log "Skipping zoxide script install: curl not available."
    return 1
  fi

  ensure_remote_install_allowed "zoxide" || return 1

  ensure_local_bin_dir
  log "Installing zoxide via official installer script"
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    | sh -s -- --bin-dir "$home_dir/.local/bin"
}

install_tailscale_linux_script() {
  if have_command tailscale; then
    return 0
  fi

  if ! have_command curl; then
    log "Skipping tailscale script install: curl not available."
    return 1
  fi

  ensure_remote_install_allowed "tailscale" || return 1

  log "Installing tailscale via official installer script"
  curl -fsSL https://tailscale.com/install.sh | sh
}

install_kitty_linux_script() {
  if have_command kitty; then
    return 0
  fi

  if ! have_command curl; then
    log "Skipping kitty script install: curl not available."
    return 1
  fi

  ensure_remote_install_allowed "kitty" || return 1

  ensure_local_bin_dir
  log "Installing kitty via official installer script"
  curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  if [[ -x "$home_dir/.local/kitty.app/bin/kitty" ]]; then
    ln -sf "$home_dir/.local/kitty.app/bin/kitty" "$home_dir/.local/bin/kitty"
    ln -sf "$home_dir/.local/kitty.app/bin/kitten" "$home_dir/.local/bin/kitten"

    mkdir -p "$home_dir/.local/share/applications"
    cp "$home_dir/.local/kitty.app/share/applications/kitty.desktop" "$home_dir/.local/share/applications/"
    cp "$home_dir/.local/kitty.app/share/applications/kitty-open.desktop" "$home_dir/.local/share/applications/"

    sed -i "s|Icon=kitty|Icon=$home_dir/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$home_dir/.local/share/applications/kitty"*.desktop
    sed -i "s|Exec=kitty|Exec=$home_dir/.local/kitty.app/bin/kitty|g" "$home_dir/.local/share/applications/kitty"*.desktop

    mkdir -p "$home_dir/.config"
    echo 'kitty.desktop' > "$home_dir/.config/xdg-terminals.list"
  fi
}

installer_function_for_package() {
  case "$1" in
    gh) printf '%s' "install_gh_linux_script" ;;
    eza) printf '%s' "install_eza_linux_script" ;;
    starship) printf '%s' "install_starship_linux_script" ;;
    zoxide) printf '%s' "install_zoxide_linux_script" ;;
    tailscale) printf '%s' "install_tailscale_linux_script" ;;
    kitty) printf '%s' "install_kitty_linux_script" ;;
    *) return 1 ;;
  esac
}

install_queued_linux_repo_packages() {
  if ((${#LINUX_REPO_PACKAGES[@]} == 0)); then
    return 0
  fi

  if [[ "$linux_repo_sources_changed" -eq 1 ]]; then
    log "Refreshing apt metadata for newly added repositories"
    sudo_if_needed apt-get update
  fi

  log "Installing packages from added apt repositories: ${LINUX_REPO_PACKAGES[*]}"
  sudo_if_needed apt-get install -y "${LINUX_REPO_PACKAGES[@]}"
}

install_linux_script_tools_if_missing() {
  local installer
  local package
  local failed=()

  for package in "${SCRIPT_PRIORITY_PACKAGES[@]}"; do
    if have_command "$package"; then
      continue
    fi

    installer="$(installer_function_for_package "$package")" || {
      failed+=("$package")
      continue
    }

    "$installer" || failed+=("$package")
  done

  if ! install_queued_linux_repo_packages; then
    for package in "${LINUX_REPO_PACKAGES[@]}"; do
      failed+=("$package")
    done
  fi

  if ((${#failed[@]})); then
    log "Script install fallback failed for: ${failed[*]}"
    log "Install them manually or adjust apt sources and rerun installer."
  fi
}

install_packages() {
  local os
  os="$(detect_os)"

  case "$os" in
    macos)
      install_homebrew_if_missing
      install_brew_bundle
      ;;
    linux)
      log "Linux detected: apt first for prerequisites, then script-priority tools (Homebrew disabled)."
      install_apt_packages
      install_linux_script_tools_if_missing
      ;;
    *)
      log "Unsupported OS: ${OSTYPE:-unknown}"
      exit 1
      ;;
  esac
}

set_default_login_shell_linux() {
  local current_login_shell
  local zsh_path

  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    log "Skipping login shell update: zsh is not installed."
    return 1
  fi

  current_login_shell="$(getent passwd "${USER:-}" 2>/dev/null | awk -F: '{print $7}')"
  if [[ -n "$current_login_shell" && "$current_login_shell" == "$zsh_path" ]]; then
    log "ok  login shell already set to zsh ($zsh_path)"
    return 0
  fi

  if ! have_command chsh; then
    log "Skipping login shell update: chsh is not available."
    return 1
  fi

  if ! grep -Fxq "$zsh_path" /etc/shells 2>/dev/null; then
    log "Skipping login shell update: $zsh_path is not listed in /etc/shells."
    log "Add it to /etc/shells, then run: chsh -s \"$zsh_path\""
    return 1
  fi

  log "Setting zsh as default login shell (you may be prompted for your password)"
  if chsh -s "$zsh_path"; then
    log "ok  login shell updated to zsh ($zsh_path)"
    return 0
  fi

  log "Could not update login shell automatically."
  log "Run manually: chsh -s \"$zsh_path\""
  return 1
}

report_linux_tools() {
  local missing=()
  local tool

  for tool in zsh tmux gh kitty starship tailscale zoxide; do
    if ! have_command "$tool"; then
      missing+=("$tool")
    fi
  done

  if ! have_command eza; then
    missing+=("eza")
  fi

  if ! have_command bat && ! have_command batcat; then
    missing+=("bat")
  fi

  if ((${#missing[@]})); then
    log "Linux tools still missing after apt setup: ${missing[*]}"
    log "Some packages may not exist in your current apt sources."
  fi
}

backup_path() {
  local target="$1"
  printf '%s.%s.bak' "$target" "$(date +%Y%m%d%H%M%S)"
}

link_file() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    log "Missing source dotfile: $source"
    exit 1
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log "ok  $target -> $source"
      return 0
    fi
    rm "$target"
  elif [[ -e "$target" ]]; then
    local backup
    backup="$(backup_path "$target")"
    mv "$target" "$backup"
    log "bak $target -> $backup"
  fi

  ln -s "$source" "$target"
  log "ln  $target -> $source"
}

write_gitconfig() {
  local target="$home_dir/.gitconfig"
  local backup
  local tmpfile

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    rm "$target"
  elif [[ -e "$target" ]]; then
    backup="$(backup_path "$target")"
    mv "$target" "$backup"
    log "bak $target -> $backup"
  fi

  tmpfile="$(mktemp)"
  cat > "$tmpfile" <<EOF
[user]
	name = $git_user_name
	email = $git_user_email
[init]
	defaultBranch = $git_default_branch
EOF

  mv "$tmpfile" "$target"
  log "wrt $target"
}

main() {
  parse_args "$@"
  install_packages
  collect_git_config_values

  link_file "$repo_root/.zshrc" "$home_dir/.zshrc"
  link_file "$repo_root/.zimrc" "$home_dir/.zimrc"
  write_gitconfig
  link_file "$repo_root/.tmux.conf" "$home_dir/.tmux.conf"
  link_file "$repo_root/.config/zsh/aliases.zsh" "$home_dir/.config/zsh/aliases.zsh"
  link_file "$repo_root/.config/starship/starship.toml" "$home_dir/.config/starship/starship.toml"
  link_file "$repo_root/.config/kitty/kitty.conf" "$home_dir/.config/kitty/kitty.conf"

  log ""
  log "Installed dotfiles from: $repo_root"
  log "Next steps:"
  log "  1. Select FiraCode Nerd Font in your terminal settings."
  log "  2. Start a new shell or run: exec zsh"
  if [[ "$(detect_os)" == linux ]]; then
    set_default_login_shell_linux || true
    log "  3. If zsh is still not your login shell, run: chsh -s \"$(command -v zsh)\""
    log "  4. If Nerd Font glyphs are missing, install FiraCode Nerd Font manually."
    report_linux_tools
  fi
}

main "$@"
