# Aliases loaded from .zshrc

if (( ${+commands[eza]} )); then
  alias ls="eza"
  alias la="eza -a"
  alias ll="eza -l"
fi

if (( ${+commands[bat]} )); then
  alias cat="bat"
elif (( ${+commands[batcat]} )); then
  alias cat="batcat"
fi

# Git helper for this repo cloned to ~/dotfiles (see README). Override path with DOTFILES_DIR.
# For a bare repo with work-tree $HOME: GIT_DIR=~/.dotfiles GIT_WORK_TREE=$HOME git ...
if [[ -d "${DOTFILES_DIR:-$HOME/dotfiles}/.git" ]]; then
  dotfiles() {
    command git -C "${DOTFILES_DIR:-$HOME/dotfiles}" "$@"
  }
fi
