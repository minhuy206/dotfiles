backup_path() {
  local target="$1"
  printf '%s.%s.bak' "$target" "$(date +%Y%m%d%H%M%S)"
}

backup_existing_path() {
  local target="$1"
  local backup

  backup="$(backup_path "$target")"
  mv "$target" "$backup"
  log "bak $target -> $backup"
}

ensure_real_dir() {
  local target="$1"

  if [[ -L "$target" ]]; then
    backup_existing_path "$target"
  elif [[ -e "$target" && ! -d "$target" ]]; then
    backup_existing_path "$target"
  fi

  mkdir -p "$target"
}

link_path() {
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
    backup_existing_path "$target"
  elif [[ -e "$target" ]]; then
    backup_existing_path "$target"
  fi

  ln -s "$source" "$target"
  log "ln  $target -> $source"
}

link_shared_configs() {
  link_path "$repo_root/shared/zsh/zshenv" "$home_dir/.zshenv"
  link_path "$repo_root/shared/zsh/zshrc"  "$home_dir/.zshrc"
  link_path "$repo_root/shared/zsh/zimrc"  "$home_dir/.zimrc"
  link_path "$repo_root/shared/tmux/tmux.conf" "$home_dir/.tmux.conf"

  link_path "$repo_root/shared/zsh/config/00-options.zsh" "$home_dir/.config/zsh/00-options.zsh"
  link_path "$repo_root/shared/zsh/config/10-zim.zsh"     "$home_dir/.config/zsh/10-zim.zsh"
  link_path "$repo_root/shared/zsh/config/20-path.zsh"    "$home_dir/.config/zsh/20-path.zsh"
  link_path "$repo_root/shared/zsh/config/30-aliases.zsh" "$home_dir/.config/zsh/30-aliases.zsh"
  link_path "$repo_root/shared/zsh/config/40-tools.zsh"   "$home_dir/.config/zsh/40-tools.zsh"
  link_path "$repo_root/shared/zsh/config/50-tmux.zsh"    "$home_dir/.config/zsh/50-tmux.zsh"
  link_path "$repo_root/shared/zsh/config/99-zoxide.zsh"  "$home_dir/.config/zsh/99-zoxide.zsh"

  link_path "$repo_root/shared/nvim" "$home_dir/.config/nvim"
  link_path "$repo_root/shared/starship/starship.toml" "$home_dir/.config/starship/starship.toml"
  link_path "$repo_root/shared/kitty/kitty.conf" "$home_dir/.config/kitty/kitty.conf"
}

link_macos_configs() {
  link_path "$repo_root/macos/zsh/25-servbay.zsh" "$home_dir/.config/zsh/25-servbay.zsh"
}

link_arch_configs() {
  link_path "$repo_root/arch/wallpapers" "$home_dir/wallpapers"

  ensure_real_dir "$home_dir/.config/hypr"
  link_path "$repo_root/arch/hypr/hyprland.lua" "$home_dir/.config/hypr/hyprland.lua"
  link_path "$repo_root/arch/hypr/modules" "$home_dir/.config/hypr/modules"
  link_path "$repo_root/arch/hyprpaper/hyprpaper.conf" "$home_dir/.config/hypr/hyprpaper.conf"
  link_path "$repo_root/arch/hypridle/hypridle.conf" "$home_dir/.config/hypr/hypridle.conf"
  link_path "$repo_root/arch/hyprlock/hyprlock.conf" "$home_dir/.config/hypr/hyprlock.conf"

  link_path "$repo_root/arch/hyprmoncfg" "$home_dir/.config/hyprmoncfg"
  link_path "$repo_root/arch/waybar" "$home_dir/.config/waybar"
  link_path "$repo_root/arch/rofi" "$home_dir/.config/rofi"
  link_path "$repo_root/arch/mako/config" "$home_dir/.config/mako/config"
}
