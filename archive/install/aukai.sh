#!/usr/bin/env bash

set -e

if [ ! -d "$GOPATH/src/aukai" ]; then
  echo "cloning aukai repo";
  if git clone git@github.com:aukai/aukai.git $GOPATH/src/aukai; then
    cd $GOPATH/src/aukai

    # https://dhoeric.github.io/2017/https-to-ssh-in-gitmodules/
    perl -i -p -e 's|https://(.*?)/|git@\1:|g' .gitmodules

    git submodule init
    git submodule update
  else
    echo "failed to clone aukai repository; add public ssh key to your profile"
    cat ~/.ssh/id_rsa.pub
  fi
fi
