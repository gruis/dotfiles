#!/usr/bin/env bash

set -e 

sudo wget -q -c https://dl.google.com/go/go1.13.11.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/gopath.sh
mkdir -p ~/go
