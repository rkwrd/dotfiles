# ~/.bashrc
# Configured for Nord Light Dotfiles

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Sane history defaults
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command and update lines/columns if needed
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set truecolor support for terminal tools
export COLORTERM=truecolor
export TERM=xterm-256color

# Source shared shell definitions if they exist
[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.fzf_nord_light" ] && . "$HOME/.fzf_nord_light"

# Initialize Starship prompt if installed
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    # Fallback prompt (simple clean Nord-ish layout)
    # \u: user, \h: host, \w: path
    PS1='\[\e[34m\]\u@\h\[\e[0m\]:\[\e[32m\]\w\[\e[0m\]\$ '
fi

# Initialize zoxide if installed
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# Set path adjustments
export PATH="$HOME/.local/bin:$PATH"
