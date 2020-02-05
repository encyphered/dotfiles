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

  if [ -d "$HOME/.oh-my-zsh" ]; then
    if [[ -z "$ZSH_CACHE_DIR" ]]; then
      export ZSH_CACHE_DIR="$HOME/.oh-my-zsh/cache"
    fi
  fi
  if [ -d $HOME/.oh-my-zsh/lib ]; then
    source $HOME/.oh-my-zsh/lib/completion.zsh
    source $HOME/.oh-my-zsh/lib/key-bindings.zsh
  fi
  if [ -d $HOME/.oh-my-zsh/plugins ]; then
    source $HOME/.oh-my-zsh/plugins/git/git.plugin.zsh
    source $HOME/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh
    source $HOME/.oh-my-zsh/plugins/docker/_docker
    source $HOME/.oh-my-zsh/plugins/common-aliases/common-aliases.plugin.zsh
  fi

  setopt interactivecomments
else
  :
fi

bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

if [ -x /usr/local/bin/kubectl ]; then
	declare -f compdef > /dev/null && source <(kubectl completion zsh)

	unalias k 2> /dev/null
  function k() {
    NS=$1 && shift 2> /dev/null && kubectl --namespace $NS $@
  }

  declare -f kubeon > /dev/null && {
    KUBE_PS1_SYMBOL_ENABLE=false
    KUBE_PS1_PREFIX='['
    KUBE_PS1_SUFFIX='] '
    KUBE_PS1_NS_ENABLE=true
    KUBE_PS1_SEPERATOR=""
    PROMPT='$(kube_ps1)'$PROMPT
    kubeon -g
  }

  unalias keti 2> /dev/null
  function keti() {
    kubectl exec $1 -itc $(kubectl get pod $1 -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n' | fzf --no-sort -1) -- $(shift 2>&1 > /dev/null && echo $@)
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
alias ga='git status -s | grep -v "^[DMA] " | fzf -m | awk "{print \$2}" | xargs -o git add'
alias grh='git status --short | grep "^[MARCD]" | sed -e "s/^[MARCD] *//g" | fzf --print0 -m | xargs -0 git reset HEAD'
alias gs='git log --pretty="%h %cr, %an: %s" --max-count=20 | fzf --no-sort | cut -f1 -d" " | xargs git show'
alias gscc='git log --pretty="%h %cr, %an: %s" --abbrev=7 --max-count=20 | fzf --no-sort | cut -f1 -d" " | xargs echo -n | pbcopy'

alias hl='highlight --base16 -O truecolor -s solarized-dark -S'

alias jqr='jq -r'

unalias grep 2> /dev/null

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

export BYOBU_PYTHON=python3
alias screen='byobu'
alias remotes="cat ~/.ssh/config|grep ^Host|grep -v '*'|sed -e 's/^Host //g'"

export LANG=en_US.UTF-8

export NVM_DIR="$HOME/.nvm"

function nvminit() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

[ -f $HOME/.secure-env.sh ] && source $HOME/.secure-env.sh 2> /dev/null

[ -f /Users/cypher/Library/Preferences/org.dystroy.broot/launcher/bash/br ] && source /Users/cypher/Library/Preferences/org.dystroy.broot/launcher/bash/br
