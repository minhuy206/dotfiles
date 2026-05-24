if [[ "$OSTYPE" == darwin* ]]; then
  export PATH="/Applications/ServBay/package/python/current/Python.framework/Versions/Current/bin:$PATH"
fi

export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

if [[ "$OSTYPE" == darwin* ]]; then
  export PATH="/Applications/ServBay/package/node/25/25.9.0/bin:$PATH"
fi

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
