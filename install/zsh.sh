#!/usr/bin/env bash

set -e 

which zsh || sudo apt-get -y install zsh 

if [ -z "$ZSH_CUSTOM" ]; then
  ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
fi

[[ -f $HOME/.oh-my-zsh/oh-my-zsh.sh ]] || wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
[[ -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]] || git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
[[ -d $ZSH_CUSTOM/plugins/zsh-syntax-highlighting ]] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

sudo chsh -s $(which zsh) $USER 
