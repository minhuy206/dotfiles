configure_git_if_enabled() {
  if [[ "$skip_git_config" -eq 1 ]]; then
    log "Skipping ~/.gitconfig setup (--skip-git-config)."
    return 0
  fi

  collect_git_config_values
  update_gitconfig
}

log_shared_next_steps() {
  log ""
  log "Installed dotfiles from: $repo_root"
  log "Next steps:"
  log "  1. Select JetBrainsMono Nerd Font in your terminal settings."
  log "  2. Start a new shell or run: exec zsh"
  log "  3. Open Neovim; lazy.nvim and Mason will install configured tools on first launch."
}
