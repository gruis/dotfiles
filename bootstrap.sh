#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE}")";

sudo apt-get update
sudo apt-get -y install mosh zsh fonts-hack-ttf exuberant-ctags ack-grep 

./install/google-cloud-sdk.sh
./install/ddns.sh

if ! sudo locale | grep -q "en.US.UTF-8"; then
  sudo locale-gen en_US.UTF-8
fi

[[ -f $HOME/.ssh/id_rsa ]] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

[[ -d $HOME/.nvm/ ]] || ./install/nvm.sh 
which zsh || ./install/zsh.sh
which ruby || ./install/ruby.sh
which docker || ./install/docker.sh
which kubectl || ./install/kubectl.sh

if which go; then
  go version | grep -q "1.13" || ./install/go.sh
else
  ./install/go.sh
fi

[[ -d $HOME/.vim/janus ]] || curl -L https://bit.ly/janus-bootstrap | bash

[[ -d .git ]] && git pull origin master;

function doIt() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude "install" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    -avh --no-perms . ~;
  # source ~/.zshrc
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;

./install/aukai.sh
