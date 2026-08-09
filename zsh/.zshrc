# ~/.zshrc
# Configured for Nord Light Dotfiles

# Truecolor support
export COLORTERM=truecolor
export TERM=xterm-256color

# Path setup
export PATH="$HOME/.local/bin:$PATH"

# History Configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# Sane Directory Navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Sane Completions Setup
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Vim-style line editing keybindings
bindkey -v
bindkey '^R' history-incremental-search-backward

# Source shared shell definitions
[ -f "$HOME/.shell_aliases" ] && source "$HOME/.shell_aliases"
[ -f "$HOME/.fzf_nord" ] && source "$HOME/.fzf_nord"

# Load plugins manually if installed (highly optimized, no bloated manager needed)
# Typical plugin paths for debian, arch, and homebrew
plugin_dirs=(
    "/usr/share/zsh-autosuggestions"
    "/usr/share/zsh/plugins/zsh-autosuggestions"
    "/opt/homebrew/share/zsh-autosuggestions"
    "/usr/share/zsh-syntax-highlighting"
    "/usr/share/zsh/plugins/zsh-syntax-highlighting"
    "/opt/homebrew/share/zsh-syntax-highlighting"
)

for dir in "${plugin_dirs[@]}"; do
    if [ -f "$dir/zsh-autosuggestions.zsh" ]; then
        source "$dir/zsh-autosuggestions.zsh"
    fi
    if [ -f "$dir/zsh-syntax-highlighting.zsh" ]; then
        source "$dir/zsh-syntax-highlighting.zsh"
    fi
done

# Initialize Starship prompt if installed
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # Simple clean default prompt if starship is missing
    PROMPT='%F{blue}%n@%m%f:%F{green}%~%f$ '
fi

# Initialize zoxide if installed
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
