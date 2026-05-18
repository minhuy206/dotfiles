for f in "$HOME/.config/zsh/"[0-9]*.zsh(N); do
  [[ -r $f ]] && source "$f"
done

if [[ "$OSTYPE" == darwin* ]]; then
  # Prefer ServBay Python direct binaries over ServBay alias wrappers.
  servbay_python_bin="/Applications/ServBay/package/python/current/Python.framework/Versions/Current/bin"
  path=("${(@)path:#$HOME/Library/Python/3.9/bin}")
  path=("$servbay_python_bin" "${(@)path:#$servbay_python_bin}")
  unset servbay_python_bin
fi
