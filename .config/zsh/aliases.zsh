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

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
