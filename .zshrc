# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="custom/glinks"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir kubecontext newline rvm go_version vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs host time)
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="↳ "
POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="white"
#POWERLEVEL9K_COLOR_SCHEME='light'
POWERLEVEL9K_MODE='awesome-fontconfig'
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(icons_test)
#ZSH_THEME="powerlevel9k/powerlevel9k"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=14"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
# plugins=(git ruby rvm vi-mode github bundler osx)
#plugins=(git ruby rvm vi-mode github osx zsh-syntax-highlighting)

# vi-mode plugin in Mavericks makes Terminal slow with vi key bindings
plugins=(
  git 
  ruby 
  rvm 
  github 
  osx 
  zsh-syntax-highlighting 
  zsh-autosuggestions
  gem 
  docker 
  docker-compose
  kubectl 
  golang
  npm
  nvm
)

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion
source $ZSH/oh-my-zsh.sh

# Customize to your needs...
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 

bindkey -v
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward


alias be="bundle exec"
export PATH=/usr/local/bin:/usr/local/sbin:$PATH:$HOME/bin:$HOME/local/bin
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export PATH=$PATH:/usr/local/git/bin

export EDITOR='vim -f --nomru -c "au VimLeave * !open -a Terminal"'

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

alias tmux="tmux -u"

HISTSIZE=SAVEHIST=99999
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GO111MODULE=on
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

export LANG=en_US.UTF-8

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`

[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh

export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm


# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc


# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f $HOME/.nvm/versions/node/v8.14.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . $HOME/.nvm/versions/node/v8.14.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh

source <(npx --shell-auto-fallback zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/snap/google-cloud-sdk/current/path.zsh.inc' ]; then . '/snap/google-cloud-sdk/current/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/snap/google-cloud-sdk/current/completion.zsh.inc' ]; then . '/snap/google-cloud-sdk/current/completion.zsh.inc'; fi
