#!/usr/bin/env bash

set -e 

# Docker-CE
#  sudo apt install apt-transport-https ca-certificates curl software-properties-common
#  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
#  sudo apt update
#  apt-cache policy docker-ce
#  sudo apt install docker-ce
#  sudo systemctl status docker

sudo apt-get install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker ${USER}
gcloud auth configure-docker --quiet --account devopsbox@strategic-hull-237304.iam.gserviceaccount.com --project strategic-hull-237304
