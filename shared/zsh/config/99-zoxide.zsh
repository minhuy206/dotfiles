if (( ${+commands[zoxide]} )); then
  eval "$(zoxide init zsh --cmd cd)"

  z() {
    cd "$@"
  }

  zi() {
    cdi "$@"
  }
fi
