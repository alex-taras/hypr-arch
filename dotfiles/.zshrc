# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_SILENT

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings
bindkey -e
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'

eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
