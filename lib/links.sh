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

link_dotfiles() {
  link_file "$repo_root/.zshenv"   "$home_dir/.zshenv"
  link_file "$repo_root/.zshrc"    "$home_dir/.zshrc"
  link_file "$repo_root/.zimrc"    "$home_dir/.zimrc"
  link_file "$repo_root/.tmux.conf" "$home_dir/.tmux.conf"
  link_file "$repo_root/.config/zsh/00-options.zsh" "$home_dir/.config/zsh/00-options.zsh"
  link_file "$repo_root/.config/zsh/10-zim.zsh"     "$home_dir/.config/zsh/10-zim.zsh"
  link_file "$repo_root/.config/zsh/20-path.zsh"    "$home_dir/.config/zsh/20-path.zsh"
  link_file "$repo_root/.config/zsh/30-aliases.zsh" "$home_dir/.config/zsh/30-aliases.zsh"
  link_file "$repo_root/.config/zsh/40-tools.zsh"   "$home_dir/.config/zsh/40-tools.zsh"
  link_file "$repo_root/.config/zsh/50-tmux.zsh"    "$home_dir/.config/zsh/50-tmux.zsh"
  link_file "$repo_root/.config/zsh/99-zoxide.zsh"  "$home_dir/.config/zsh/99-zoxide.zsh"
  link_file "$repo_root/.config/nvim"               "$home_dir/.config/nvim"
  link_file "$repo_root/.config/starship/starship.toml" "$home_dir/.config/starship/starship.toml"
  link_file "$repo_root/.config/kitty/kitty.conf"   "$home_dir/.config/kitty/kitty.conf"

  if [[ "$(detect_os)" == arch ]]; then
    link_file "$repo_root/.config/hypr/hyprland.conf"            "$home_dir/.config/hypr/hyprland.conf"
    link_file "$repo_root/.config/hypr/hyprland.lua"             "$home_dir/.config/hypr/hyprland.lua"
    link_file "$repo_root/.config/hypr/hyprpaper.conf"           "$home_dir/.config/hypr/hyprpaper.conf"
    link_file "$repo_root/.config/hypr/hypridle.conf"            "$home_dir/.config/hypr/hypridle.conf"
    link_file "$repo_root/.config/waybar/config.jsonc"           "$home_dir/.config/waybar/config.jsonc"
    link_file "$repo_root/.config/waybar/style.css"             "$home_dir/.config/waybar/style.css"
    link_file "$repo_root/.config/waybar/colors/one-dark.css"   "$home_dir/.config/waybar/colors/one-dark.css"
    link_file "$repo_root/.config/waybar/scripts/launch.sh"     "$home_dir/.config/waybar/scripts/launch.sh"
    link_file "$repo_root/.config/mako/config"                   "$home_dir/.config/mako/config"
    link_file "$repo_root/.config/rofi/config.rasi"              "$home_dir/.config/rofi/config.rasi"
  fi
}
