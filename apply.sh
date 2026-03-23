#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pairs: "source_relative_path|target_absolute_path"
CONFIGS=(
  "vim/.vimrc|$HOME/.vimrc"
  "vim/colors/molokai.vim|$HOME/.vim/colors/molokai.vim"
  "ghostty/config|$HOME/.config/ghostty/config"
)

ask() {
  local prompt="$1"
  while true; do
    read -rp "$prompt [y/N] " answer
    case "$answer" in
      [Yy]*) return 0 ;;
      [Nn]*|"") return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

symlink_config() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  echo ""
  echo "Config : $dst"
  echo "Source : $src"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "Already linked — skipping."
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    echo "A file already exists at $dst."
    if ask "Back it up and replace with a symlink?"; then
      local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
      mv "$dst" "$backup"
      echo "Backed up to $backup"
    else
      echo "Skipped."
      return
    fi
  else
    if ! ask "Create symlink?"; then
      echo "Skipped."
      return
    fi
  fi

  mkdir -p "$dst_dir"
  ln -sf "$src" "$dst"
  echo "Linked."
}

check_deps() {
  echo ""
  echo "=== Checking dependencies ==="

  # oh-my-zsh (required for full zsh config)
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "oh-my-zsh not found."
    if ask "Install oh-my-zsh now?"; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installation failed. Skipping zsh config."
        SKIP_ZSH=1
      fi
    elif ! ask "Continue applying zsh config without oh-my-zsh?"; then
      SKIP_ZSH=1
    fi
  fi

  # ghostty
  if ! command -v ghostty &>/dev/null && [[ ! -d "/Applications/Ghostty.app" ]]; then
    echo "NOTE: Ghostty not found — ghostty config will be skipped."
    SKIP_GHOSTTY=1
  fi
}

apply_prompt() {
  local src="$REPO_DIR/zsh/prompt.zsh"
  local dst="$HOME/.zsh_prompt"
  local zshrc="$HOME/.zshrc"
  local source_line="[[ -f ~/.zsh_prompt ]] && source ~/.zsh_prompt"

  echo ""
  echo "=== Zsh prompt ==="
  symlink_config "$src" "$dst"

  if [[ "$SKIP_ZSH" == 1 ]]; then return; fi

  if grep -qF "$source_line" "$zshrc" 2>/dev/null; then
    echo "~/.zshrc already sources prompt — skipping."
  else
    echo ""
    echo "Config : ~/.zshrc (append source line only)"
    if ask "Append 'source ~/.zsh_prompt' to ~/.zshrc?"; then
      echo "" >> "$zshrc"
      echo "# Prompt (managed by configs repo)" >> "$zshrc"
      echo "$source_line" >> "$zshrc"
      echo "Appended."
    else
      echo "Skipped."
    fi
  fi
}

SKIP_ZSH=0
SKIP_GHOSTTY=0

echo "=== Applying configs from $REPO_DIR ==="

check_deps

apply_prompt

for entry in "${CONFIGS[@]}"; do
  src_rel="${entry%%|*}"
  dst="${entry##*|}"
  src="$REPO_DIR/$src_rel"

  if [[ ! -f "$src" ]]; then
    echo ""
    echo "WARNING: Source not found, skipping: $src"
    continue
  fi

  [[ "$src_rel" == ghostty/* && "$SKIP_GHOSTTY" == 1 ]] && continue

  symlink_config "$src" "$dst"
done

echo ""
echo "Done."
