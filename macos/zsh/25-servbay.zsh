if [[ "$OSTYPE" == darwin* ]]; then
  servbay_python_bin="/Applications/ServBay/package/python/current/Python.framework/Versions/Current/bin"
  servbay_node_bin="/Applications/ServBay/package/node/25/25.9.0/bin"

  path=("${(@)path:#$HOME/Library/Python/3.9/bin}")
  [[ -d "$servbay_python_bin" ]] && path=("$servbay_python_bin" "${(@)path:#$servbay_python_bin}")
  [[ -d "$servbay_node_bin" ]] && path=("$servbay_node_bin" "${(@)path:#$servbay_node_bin}")

  unset servbay_python_bin servbay_node_bin
fi
