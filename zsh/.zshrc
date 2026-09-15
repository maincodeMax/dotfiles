# Ensure system bins always exist (Ghostty / nested tools sometimes drop them).
# Without /bin and /usr/bin, matilda's shell tool cannot find bash/git.
if [[ ":$PATH:" != *":/usr/bin:"* ]] || [[ ":$PATH:" != *":/bin:"* ]]; then
  export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
fi

# User bins — ~/.local/bin first so matilda/claude wrappers always resolve
export PATH="$HOME/.local/bin:$HOME/.hermes/node/bin:$PATH"
alias claude='claude --dangerously-skip-permissions'
# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="ayu-dark"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Autosuggestions: ayu blue
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=81,dim"

# Syntax highlighting (ayu palette)
ZSH_HIGHLIGHT_STYLES[command]='fg=107,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=107,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=107,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=107'
ZSH_HIGHLIGHT_STYLES[path]='fg=81'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=215'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=215'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=196'

# History
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Android SDK (adb, emulator) — default install path from Android Studio
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
export PATH="$PATH:$HOME/.maestro/bin"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Default editor
export EDITOR="zed --wait"
export VISUAL="zed --wait"
export GIT_EDITOR="zed --wait"

# herdr isolated instances — one per Ghostty window
alias hl='herdr-iso left'
alias hr='herdr-iso right'
alias hs='herdr-iso scratch'

# kimi-code
export PATH="/Users/max/.kimi-code/bin:$PATH"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# Added by the BaseRT installer
export PATH="/Users/max/.basert:$PATH"

# Added by Devin
export PATH="/Users/max/.codeium/windsurf/bin:$PATH"

# bun completions
[ -s "/Users/max/.bun/_bun" ] && source "/Users/max/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
