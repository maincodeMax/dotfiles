#!/bin/sh
# Symlink every config in this repo into place. Idempotent: an existing real
# file or directory at the target is moved aside to <target>.bak.<timestamp>.
set -eu
D="$(cd "$(dirname "$0")" && pwd)"
ts="$(date +%Y%m%d%H%M%S)"
link() {
  src="$D/$1"; dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "ok      $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak.$ts"; echo "backup  $dst -> $dst.bak.$ts"; fi
  ln -s "$src" "$dst"; echo "linked  $dst -> $src"
}
link nvim               "$HOME/.config/nvim"
link ghostty/config     "$HOME/.config/ghostty/config"
link herdr/config.toml  "$HOME/.config/herdr/config.toml"
link zsh/.zshrc         "$HOME/.zshrc"
link zsh/.zprofile      "$HOME/.zprofile"
link git/.gitconfig     "$HOME/.gitconfig"
[ -f "$HOME/.zshenv" ] || echo "note: create ~/.zshenv from zsh/zshenv.example (tokens are not tracked)"
