export P10K=$HOME/.p10k

if [ ! -z "$P10K" ]; then
  typeset -gix P9K_SSH=0
  typeset -gx _P9K_SSH_TTY=$TTY

  source $P10K/powerlevel10k.zsh-theme
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completion cache for external tools. Must be added to fpath before compinit scans it.
ZSH_COMPCACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
[[ -d $ZSH_COMPCACHE ]] || mkdir -p $ZSH_COMPCACHE
# -e, not -s: the plugin's background job truncates the file before rewriting it,
# and a transient 0-byte read must not trigger a full .zcompdump rebuild.
if (( $+commands[kubectl] )) && [[ ! -e $ZSH_COMPCACHE/_kubectl || $commands[kubectl] -nt $ZSH_COMPCACHE/_kubectl ]]; then
  kubectl completion zsh > $ZSH_COMPCACHE/_kubectl
  rm -f ${ZDOTDIR:-$HOME}/.zcompdump  # invalidate the dump, or compinit -C would skip the new function
fi
fpath=($ZSH_COMPCACHE $fpath)

autoload -U compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh-24) ]]; then
  compinit -C
else
  compinit
fi

  OMZ="$HOME/.oh-my-zsh"
  if [ -d "$OMZ" ]; then
    if [[ -z "$ZSH_CACHE_DIR" ]]; then
      # Point $ZSH_CACHE_DIR/completions at ZSH_COMPCACHE above, so the kubectl
      # plugin's background job keeps the fpath cache up to date on its own.
      export ZSH_CACHE_DIR="${ZSH_COMPCACHE:h}"
    fi
  fi
  if [ -d "$OMZ/lib" ]; then
    source $OMZ/lib/completion.zsh
    source $OMZ/lib/key-bindings.zsh
    source $OMZ/lib/history.zsh
  fi
  if [ -d "$OMZ/plugins" ]; then
    source $OMZ/plugins/git/git.plugin.zsh
    source $OMZ/plugins/kubectl/kubectl.plugin.zsh
    source $OMZ/plugins/common-aliases/common-aliases.plugin.zsh
    source $OMZ/plugins/gradle/gradle.plugin.zsh
    source $OMZ/plugins/aws/aws.plugin.zsh
  fi

  setopt interactivecomments
else
  :
fi

bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

[ -d $HOME/.zsh/zsh-completions/src ] && fpath=($HOME/.zsh/zsh-completions/src $fpath)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

AUTOENV_FILE_ENTER=.env
source ~/.zsh/zsh-autoenv/autoenv.zsh

export HOMEBREW_PREFIX="/opt/homebrew";
if [ -d "$HOMEBREW_PREFIX" ]; then
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
  export HOMEBREW_REPOSITORY="/opt/homebrew";
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi

export LSCOLORS=exfxcxdxbxegedabagacad

alias ls='ls -G'
alias rm='rm -i'

alias vim="nvim"
alias vi="nvim"
alias vimdiff="nvim -d"
export EDITOR="nvim"

alias gfu='git fetch upstream'
alias grbi2='git rebase -i HEAD~2'
alias grbi3='git rebase -i HEAD~3'
alias grbi4='git rebase -i HEAD~4'
alias grbi5='git rebase -i HEAD~5'
alias grbi6='git rebase -i HEAD~6'
alias grbi7='git rebase -i HEAD~7'
alias grbi8='git rebase -i HEAD~8'
alias grbi9='git rebase -i HEAD~9'
alias glog='git log --pretty="%C(yellow)%h %C(Green)%cr%C(dim white), %C(no-dim cyan)%an%C(dim white): %C(reset)%s%C(auto)%d" --graph'
alias gloga='glog --all'
alias grh='git status --short | grep "^[MARCD]" | sed -e "s/^[MARCD] *//g" | fzf --print0 -m | xargs -0 git reset HEAD'
alias gs='git log --pretty="%h %cr, %an: %s" --max-count=20 | fzf --no-sort | cut -f1 -d" " | xargs git show'
unalias ga
function ga() {
  if [ $# -eq 0 ] || [ "$1" = "-p" ]; then
    git status -s | grep -v "^[DMAR] " | fzf -m | awk "{print \$2}" | xargs -o git add $@
  else
    git add $@
  fi
}
function gscc() {
  git log --pretty="%h %cr, %an: %s" --abbrev=7 --max-count=20 $1 | fzf --no-sort | cut -f1 -d" " | xargs echo -n | pbcopy
}

alias hl='highlight --base16 -O truecolor -s solarized-dark -S'

alias jqr='jq -r'

unalias grep 2> /dev/null

(( $+commands[eza] )) && alias ls='eza --icons' && export EZA_CONFIG_DIR="${HOME}/.config/eza"
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[gsed] )) && alias sed=gsed
(( $+commands[gawk] )) && alias awk=gawk

if command -v pyenv > /dev/null; then
  _pyenv_cache="${HOME}/.cache/zsh/pyenv-init.zsh"
  if [[ ! -s $_pyenv_cache || $commands[pyenv] -nt $_pyenv_cache ]]; then
    mkdir -p ${_pyenv_cache:h}
    { pyenv init - --no-rehash zsh; pyenv virtualenv-init - zsh } > $_pyenv_cache
  fi
  source $_pyenv_cache
  unset _pyenv_cache
fi

export BYOBU_PYTHON=python3
function screen() {
  if [[ $# -eq 0 ]]; then
    byobu new-session
    return $?
  fi

  case "$1" in
    -ls)
      byobu list-sessions
      return $?
      ;;
    -dr)
      if [[ -z "$2" ]]; then
        local sessions
        sessions=($(byobu list-sessions -F '#{session_name}'))
        if [[ ${#sessions[@]} -eq 1 ]]; then
          byobu attach-session -d -t "${sessions[1]}"
          return $?
        elif [[ ${#sessions[@]} -gt 1 ]]; then
          echo "There are several screens on:" >&2
          byobu list-sessions >&2
          return 2
        else
          return 3
        fi
      elif [[ "$1" == "-dr" && -n "$2" ]]; then
        byobu attach-session -d -t "$2"
        return $?
      fi
      ;;
  esac

  echo "Invalid parameter"
  return 1
}

export LANG=en_US.UTF-8


if [[ -o interactive ]]; then
  lazynvm() {
    unset -f nvm node npm npx 2> /dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
  }

  nvm() {
    lazynvm
    nvm $@
  }

  node() {
    lazynvm
    node $@
  }

  npm() {
    lazynvm
    npm $@
  }

  npx() {
    lazynvm
    npx $@
  }
else
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

[ -f $HOME/.secure-env.sh ] && source $HOME/.secure-env.sh 2> /dev/null
[ -f $HOME/.personal-env.sh ] && source $HOME/.personal-env.sh 2> /dev/null

[ -f $HOME/.config/broot/launcher/bash/br ] && source $HOME/.config/broot/launcher/bash/br

awsctx() {
  if [ "$1" = "-" ]; then
    unset AWS_PROFILE && return 0
  fi

  if [ -z "$1" ]; then
    _AWS_PROFILE=$(cat ~/.aws/config|grep '^\[profile'|awk '{print $2}'|sed -e 's/]//g'|fzf)
  else
    _AWS_PROFILE=$1
  fi

  cat ~/.aws/config|grep '^\[profile'|awk '{print $2}'|sed -e 's/]//g'|grep -q "^${_AWS_PROFILE}$" || return 1

  export AWS_PROFILE=$_AWS_PROFILE
  sed -i'' -e '/^export AWS_PROFILE/d' ~/.personal-env.sh && echo "export AWS_PROFILE=${1}" >> ~/.personal-env.sh
}
(( $+commands[aws_completer] )) && complete -C $commands[aws_completer] aws

if [[ -o interactive ]]; then
  lazygoenv() {
    unset -f go goenv 2> /dev/null
    export GOENV_ROOT="$HOME/.goenv"
    export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"
  }

  go() {
    lazygoenv
    go "$@"
  }

  goenv() {
    lazygoenv
    goenv "$@"
  }
else
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"
fi

[ -d "${HOME}/.jenv" ] && export PATH="$HOME/.jenv/bin:$PATH" && eval "$(jenv init -)" || true

alias tf=terraform
export GPG_TTY=$TTY

function kubecfg() {
  local ctx
  [ "$1" = "clear" ] && unset KUBECONFIG && return 0
  ctx=$(kubectl config view -o json|jq '.contexts[] | .name' -r|fzf) && \
    kubectl config view --minify --flatten --context $ctx > "${HOME}/.kube/config-${ctx}" && \
    chmod 600 "${HOME}/.kube/config-${ctx}" && \
    export KUBECONFIG="${HOME}/.kube/config-${ctx}"
}

export FX_THEME=2

set -o vi

[ -d "${HOME}/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "${HOME}/bin" ] && export PATH="$HOME/bin:$PATH"

if (( $+commands[kubectl] )); then
  # Completion is autoloaded by compinit from $ZSH_COMPCACHE/_kubectl above.

  declare -f kubeon > /dev/null && {
    KUBE_PS1_SYMBOL_ENABLE=false
    KUBE_PS1_PREFIX='['
    KUBE_PS1_SUFFIX='] '
    KUBE_PS1_NS_ENABLE=true
    KUBE_PS1_SEPERATOR=""
    PROMPT='$(kube_ps1)'$PROMPT
    kubeon -g
  }

  if (( $+commands[kubectl-fzf] )); then
    alias kz='kubectl fzf'
    alias kzl='kz logs'
    alias kzlc='kz logs -c'
    alias kzlf='kz logs -f'
    alias kzlfc='kz logs -fc'
    alias kzgp='kz get pod'
    alias kzgpc="kubectl get pod --no-headers|fzf|awk '{print \$1}'|xargs echo -n |pbcopy"

    alias keti='kz exec -it'
    alias ketic='kz exec -itc'
    alias ke='kz exec'
  fi
  alias kgp='kubectl get pod'
  alias kgpw='kubectl get pod --watch'
  alias klfc='kubectl logs -f -c'
  alias kd='kubectl describe'
  function kzaf() {
    /bin/ls | fzf | xargs kubectl apply -f
  }

fi

export ZSH_AI_PROVIDER="openai"
[ -f "${HOME}/.zsh/zsh-ai/zsh-ai.plugin.zsh" ] && source "${HOME}/.zsh/zsh-ai/zsh-ai.plugin.zsh"

clear-scrollback() {
  printf '\033[2J\033[3J\033[H'
  zle reset-prompt
}
zle -N clear-scrollback
bindkey '^K' clear-scrollback
