alias c="clear"
alias dir='find . -maxdepth 1 -type d -regex "\.\/[^.].+"'


# aliases with dependencies
command -v nvim >/dev/null && alias vim=nvim || \
        echo "Missing dependency (nvim). Failed to alias vim -> nvim"
command -v find >/dev/null && alias find='find -E' || \
        echo "Missing dependency (find -E). Failed to alias find -> find -E"
command -v egrep >/dev/null && alias grep=egrep || \
        echo "Missing dependency (egrep). Failed to alias grep -> egrep"
command -v pygmentize >/dev/null && alias ccat='pygmentize -g' >/dev/null || \
        echo "Missing dependency (pygmentize -g). Failed to alias ccat -> pygmentize -g"
command -v hub >/dev/null && alias git=hub || \
        echo "Missing dependency (hub). Failed to alias git -> hub"
command -v tmux >/dev/null && alias tls='tmux list-sessions' || \
        echo "Missing dependency (tmux). Failed to alias tls -> tmux list-sessions"


# exa-specific aliases
command -v exa >/dev/null && alias ls='exa' || \
        echo 'Missing dependency (exa). Failed to alias ls -> exa'
command -v exa >/dev/null && alias ll='exa -l' || \
        echo 'Missing dependency (exa). Failed to alias ll -> exa -l' && \
        alias ll='ls -l' # fallback to ls -l
command -v exa >/dev/null && alias la='exa -la' || \
        echo 'Missing dependency (exa). Failed to alias la -> exa -la' && \
        alias la='ls -la' # fallback to ls -la
command -v exa >/dev/null && alias lt='exa --tree' || \
        echo 'Missing dependency (exa). Failed to alias lt -> exa --tree'


if command -v kubectl >/dev/null; then
  # kubernetes aliases
  alias kpods='kubectl get pods'
  alias kdeploys='kubectl get deployments'

  # the following functions rely on gcloud being installed
  if command -v gcloud >/dev/null; then
    function kedit {
      deployment=$1
      kubectl edit deployments $deployment
    }

    function kswitch {
      environment=$1
      gcloud container clusters get-credentials $environment
    }
  fi

  # kubernetes functions
  function kush {
    name=$1
    cmd=${2-/bin/bash}
    kubectl exec -it $name -- $cmd
  }
fi


# git-specific aliases
git config --global alias.recent 'for-each-ref --count=10 --sort=-committerdate refs/heads/ --format="%(refname:short)"'
git config --global alias.today 'log --since=00:00:00 --all --no-merges --oneline --author="$(git config --get user.email)"'
git config --global alias.conflicts 'diff --name-only --diff-filter=U'

alias glp="git log --graph --pretty=format:'%Cred%h%Creset -%Cblue %an %Creset - %C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gprom="git pull --rebase origin master"
alias gcan='git commit --amend --no-edit'
alias gpf='git push --force'
alias gds='git diff --staged'


# elixir-specific aliases
alias ism='iex -S mix'
alias tism='MIX_ENV=test iex -S mix'
alias mdg='mix deps.get'
