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
    source $OMZ/plugins/aws/aws.plugin.zsh
  fi

  setopt interactivecomments
else
  :
fi

bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -d "${HOME}/bin" ] && export PATH="$HOME/bin:$PATH"
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
  export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
fi

if [ -x "$(which kubectl)" ]; then
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

  if [ -x "$(which kubectl-fzf)" ]; then
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

[ -x "$(which exa)" ] && alias ls='exa --icons'
[ -x "$(which bat)" ] && alias cat='bat --paging=never --style=plain'
[ -x "$(which gsed)" ] && alias sed=gsed
[ -x "$(which gawk)" ] && alias awk=gawk

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if which pyenv > /dev/null; then
  eval "$(pyenv init --path)" > /dev/null
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

[ -f $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br ] && source $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br

awsctx() {
  [ -z "$1" ] && export AWS_PROFILE=$(cat ~/.aws/config|grep '^\[profile'|awk '{print $2}'|sed -e 's/]//g'|fzf) || export AWS_PROFILE=$1
}
[ -x "$(which aws_completer)" ] && complete -C $(which aws_completer) aws

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

[ -d "${HOME}/.jenv" ] && export PATH="$HOME/.jenv/bin:$PATH" && eval "$(jenv init -)" || true

randpwd() {
  ruby -e 'i = (ARGV[0] or 20).to_i
  j = (i/3.0).floor
  k = (i/10.0).ceil
  l = (ARGV[1] or 0).to_i
  m = i - (j + k + l)

  print j.times.map{("A".."Z").to_a.shuffle[0]}.join
  print m.times.map{("a".."z").to_a.shuffle[0]}.join
  print "%02d" % ((rand*(10**k)).floor)
  print "[]{}#%^*+=_~.,?!".split("").shuffle[0..l-1].join if l > 0
  puts' $1 $2
}

alias tf='[ -z "$AWS_PROFILE" ] && { echo "No \$AWS_PROFILE set"; return 1 } || terraform'
export GPG_TTY=$(tty)

function kubecfg() {
  local ctx
  [ "$1" = "clear" ] && unset KUBECONFIG && return 0
  ctx=$(kubectl config view -o json|jq '.contexts[] | .name' -r|fzf) && \
    kubectl config view --minify --flatten --context $ctx > "${HOME}/.kube/config-${ctx}" && \
    chmod 600 "${HOME}/.kube/config-${ctx}" && \
    export KUBECONFIG="${HOME}/.kube/config-${ctx}"
}

export FX_THEME=2
