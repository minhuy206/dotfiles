if (( ${+commands[tmux]} )) \
  && [[ -o interactive ]] \
  && [[ -z "${TMUX:-}" ]] \
  && [[ "${DISABLE_AUTO_TMUX:-0}" != "1" ]]; then
  exec tmux new-session -A -s main
fi
