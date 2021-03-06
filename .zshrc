#export ZSH=$HOME/.oh-my-zsh
export P10K=$HOME/.p10k

if [ ! -z "$ZSH" ]; then
  ENABLE_CORRECTION="true"
  DISABLE_UNTRACKED_FILES_DIRTY="true"
  HIST_STAMPS="yyyy-mm-dd"
  ZSH_THEME="robbyrussell"

  plugins=(
    git
    kubectl
    docker
    fasd
    kube-ps1
  )

  source $ZSH/oh-my-zsh.sh
elif [ ! -z "$P10K" ]; then
  source $P10K/powerlevel10k.zsh-theme
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  autoload -U compinit && compinit

  OMZ="$HOME/.oh-my-zsh"
  if [ -d "$OMZ" ]; then
    if [[ -z "$ZSH_CACHE_DIR" ]]; then
      export ZSH_CACHE_DIR="$OMZ/cache"
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
  fi

  setopt interactivecomments
else
  :
fi

bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

if [ -x /usr/local/bin/kubectl ]; then
  declare -f compdef > /dev/null && source <(kubectl completion zsh)

  declare -f kubeon > /dev/null && {
    KUBE_PS1_SYMBOL_ENABLE=false
    KUBE_PS1_PREFIX='['
    KUBE_PS1_SUFFIX='] '
    KUBE_PS1_NS_ENABLE=true
    KUBE_PS1_SEPERATOR=""
    PROMPT='$(kube_ps1)'$PROMPT
    kubeon -g
  }

  function kfzf() {
    local namespace resource_type pattern args opts extra_args obj
  
    if [[ "${1}" == "get" || "${1}" == "delete" || "${1}" == "describe" || "${1}" == "edit" ]]; then
      args="${1} ${2}"
      resource_type=$2
      shift; shift
    elif [[ "${1}" == "rollout" && "${2}" == "restart" ]]; then
      args="${1} ${2}"
      resource_type=$(echo "${3}"|awk -F/ '{print $1}')
      pattern=$(echo "${3}"|awk -F/ '{print $2}')
      shift; shift; shift
    else
      args="${1}"
      resource_type="pod"
      shift
    fi
  
    while true; do
      [ $# -eq 0 ] && break || true
      
      case "$1" in
        --)
          break ;;
        -*[co])
          opts="${opts} $1 $2"; shift ;;
        -*n)
          opts="${opts} $1 $2"; namespace=$2; shift ;;
        --*)
          opts="${opts} $1 $2"; shift ;;
        -*)
          opts="${opts} $1" ;;
        *)
          [ -z "${pattern}" ] && pattern=$1 || break ;;
      esac

      shift
    done

    args=($(echo $args))
    opts=($(echo $opts))
    extra_args=($(echo $@))

    ns_args=($([ -z "${namespace}" ] && echo "" || echo "-n ${namespace}"))

    if [ -z "${pattern}" ]; then
      obj=$(kubectl get $resource_type $ns_args --no-headers | fzf --tac --no-sort | awk '{print $1}' || return 1)
    else
      obj=$(kubectl get $resource_type $ns_args --no-headers | grep $pattern)
      if [ $(echo "$obj" | wc -l) -eq 1 ]; then
        obj=$(echo "$obj" | awk '{print $1}')
      else
        obj=$(echo "$obj" | fzf --tac --no-sort | awk '{print $1}' || return 1)
      fi
    fi

    [ -z "${obj}" ] && { return 1; }

    if [[ "${args}" =~ "^rollout " ]]; then
      obj="${resource_type}/${obj}"
    fi

    echo "+ kubectl ${args} ${obj} ${opts} ${extra_args}" > /dev/stderr
    kubectl $args $obj $opts $extra_args
  }
  alias kz='kfzf'
  alias kzlf='kz logs -fc app'
  alias kzgp='kz get pod'
  alias kzgpc="kubectl get pod --no-headers|fzf|awk '{print \$1}'|xargs echo -n |pbcopy"

  alias keti='kfzf exec -it'
  alias ke='kfzf exec'
  alias kgp='kubectl get pod'
  alias kgpw='kubectl get pod --watch'
  function kzaf() {
    /bin/ls | fzf | xargs kubectl apply -f
  }

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
    git status -s | grep -v "^[DMA] " | fzf -m | awk "{print \$2}" | xargs -o git add $@
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

[ -x "/usr/local/bin/exa" ] && alias ls='exa --icons'

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if which pyenv > /dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)" > /dev/null
  if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
fi

export BYOBU_PYTHON=python3
alias screen='byobu'

export LANG=en_US.UTF-8

export NVM_DIR="$HOME/.nvm"

function nvminit() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

[ -f $HOME/.secure-env.sh ] && source $HOME/.secure-env.sh 2> /dev/null

[ -f /Users/cypher/Library/Preferences/org.dystroy.broot/launcher/bash/br ] && source /Users/cypher/Library/Preferences/org.dystroy.broot/launcher/bash/br

_fzf_complete_docker() {
  local cmd=$3
  if [ "${cmd}" == "rmi" ] || [ "${cmd}" == "push" ]; then
    docker images | fzf --no-sort --layout=reverse --header-lines=1 --inline-info --multi | awk '{ if($2=="<none>") printf("%s ", $3); else printf("%s:%s ", $1, $2) }' | sed -e 's/ $//g'
  elif [ "${cmd}" == "pull" ] || [ "${cmd}" == "tag" ]; then
    docker images | fzf --no-sort --layout=reverse --header-lines=1 --inline-info | awk '{ printf("%s:%s", $1, $2) }'
  fi
}

complete -F _fzf_complete_docker -o default -o bashdefault -S '' docker

awsctx() {
  export AWS_PROFILE=$(cat ~/.aws/config|grep '^\[profile'|awk '{print $2}'|sed -e 's/]//g'|fzf)
}

export GOPATH=$HOME/go
export PATH="${GOPATH}/bin:$PATH"

[ -d "${HOME}/.jenv" ] && export PATH="$HOME/.jenv/bin:$PATH" && eval "$(jenv init -)"
[ -d "${HOME}/bin" ] && export PATH="$HOME/bin:$PATH"
