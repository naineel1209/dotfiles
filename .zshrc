# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  docker
  docker-compose
  kubectl
  terraform
  aws
  npm
  python
  sudo
  history
  z
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===== PATH =====
export PATH="$HOME/.local/bin:$PATH"

# ===== Aliases =====
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --git'
alias tree='eza --tree --icons'
alias cat='bat --style=plain'
alias grep='rg'
alias find='fd'

alias tf='terraform'
alias k='kubectl'
alias d='docker'
alias dc='docker compose'
alias gs='git status'
alias gp='git pull'
alias lg='lazygit'
alias reload='source ~/.zshrc'

alias winhome='cd /mnt/c/Users/$USER'
alias explorer='explorer.exe .'

# ===== NVM =====
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ===== pyenv =====
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# ===== Go =====
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# ===== Rust =====
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ===== tfenv =====
export PATH="$HOME/.tfenv/bin:$PATH"

# ===== zoxide =====
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ===== direnv =====
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# ===== FZF =====
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export GOPATH=$HOME/go

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
