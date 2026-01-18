export EDITOR=nvim
export VISUAL=nvim

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  sudo
  z
  extract
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt NO_FLOW_CONTROL
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

install_and_source_plugin() {
  local repo_url="$1"
  local install_dir="$2"
  local source_file="$3"
  local plugin_name="$4"
  
  if [[ -f "$install_dir/$source_file" ]]; then
    source "$install_dir/$source_file"
    return 0
  fi
  
  if ! command -v git &> /dev/null; then
    echo "Error: git not found. Cannot install $plugin_name"
    echo "Install git and restart shell"
    return 1
  fi
  
  echo "Installing $plugin_name..."
  mkdir -p "$(dirname "$install_dir")"
  
  if git clone "$repo_url" "$install_dir"; then
    echo "✓ $plugin_name installed"
    source "$install_dir/$source_file"
  else
    echo "✗ Failed to install $plugin_name"
  fi
 }

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' special-dirs true

# install_and_source_plugin \
#   "https://github.com/Aloxaf/fzf-tab" \
#   "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/fzf-tab" \
#   "fzf-tab.plugin.zsh" \
#   "fzf-tab"

# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'

install_and_source_plugin \
  "https://github.com/zsh-users/zsh-syntax-highlighting" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh-syntax-highlighting" \
  "zsh-syntax-highlighting.zsh" \
  "zsh-syntax-highlighting"

install_and_source_plugin \
  "https://github.com/zsh-users/zsh-autosuggestions" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh-autosuggestions" \
  "zsh-autosuggestions.zsh" \
  "zsh-autosuggestions"

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
autoload -Uz history-search-end

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N history-search-end

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[C' autosuggest-accept

# Ctrl+U: Clear line
bindkey '^U' backward-kill-line

# Ctrl+W: Delete a word (usually default, but explicitly set)
bindkey '^W' backward-kill-word

alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -F'
alias rgr='ranger'

alias g='git'
alias gs='git status'
alias gd='git diff'
alias glg='git log --oneline --graph --decorate'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

alias v='nvim'
alias vi='nvim'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if ! command -v bat &> /dev/null; then
  alias bat='batcat'
fi

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

mkcd() { mkdir -p "$1" && cd "$1"; }

# export PATH="$HOME/bin:$PATH"
# export PATH="$HOME/.local/bin:$PATH"

# if [[ -f ~/.fzf.zsh ]]; then
#   source ~/.fzf.zsh
# fi
