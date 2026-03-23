# configs

Personal config files for replicating my setup across machines.

## Contents

| File | Target | Notes |
|------|--------|-------|
| `vim/.vimrc` | `~/.vimrc` | |
| `vim/colors/molokai.vim` | `~/.vim/colors/molokai.vim` | Bundled colorscheme |
| `zsh/prompt.zsh` | `~/.zsh_prompt` | Sourced from `~/.zshrc`, does not replace it |
| `ghostty/config` | `~/.config/ghostty/config` | |

## Apply

Run the apply script to symlink configs to their expected locations. It will prompt before each change and back up any existing files.

```sh
./apply.sh
```

- Configs are symlinked (not copied), so future edits in this repo take effect immediately.
- If oh-my-zsh is missing, the script will offer to install it.
- The zsh prompt config appends a single `source` line to your existing `~/.zshrc` — it does not replace it.
- Ghostty config is skipped if Ghostty is not installed.
