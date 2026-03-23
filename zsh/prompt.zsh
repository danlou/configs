# Prompt config — sourced from ~/.zshrc after oh-my-zsh (if present).

if command -v git_prompt_info &>/dev/null; then
  # oh-my-zsh is loaded: use its git_prompt_info.
  # Must be set here (after oh-my-zsh) to avoid being overridden by lib/git.zsh.
  ZSH_THEME_GIT_PROMPT_PREFIX=" %F{242}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
  ZSH_THEME_GIT_PROMPT_DIRTY="%F{218}*%f"
  ZSH_THEME_GIT_PROMPT_CLEAN=""
  _git_info() { git_prompt_info }
else
  _git_info() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    echo " %F{242}$branch%f"
  }
fi

_env_info() {
  [[ -n "$VIRTUAL_ENV" ]] && echo " %F{242}($(basename $VIRTUAL_ENV))%f"
}

# Two-line prompt: path + branch on line 1, ❯ on line 2
PROMPT='%F{blue}%~%f$(_git_info)$(_env_info)
%(?.%F{magenta}.%F{red})❯%f '

RPROMPT='%F{242}%*%f'
