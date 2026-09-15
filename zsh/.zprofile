
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Default editor
export EDITOR="zed --wait"
export VISUAL="zed --wait"
export GIT_EDITOR="zed --wait"

# Hermes Node + Matilda (CLI tools)
export PATH="$HOME/.local/bin:$HOME/.hermes/node/bin:$PATH"
