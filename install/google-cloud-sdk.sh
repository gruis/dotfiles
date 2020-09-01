#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "./utils.sh" \
    && progress "google cloud sdk"

if [ ! -f "/etc/apt/sources.list.d/google-cloud-sdk.list" ]; then
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
fi
which gpg || sudo apt-get -y install apt-transport-https ca-certificates gnupg
[[ -f "/usr/share/keyrings/cloud.google.gpg" ]]  || curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
if ! which gcloud; then
  sudo apt-get update && sudo apt-get -y install google-cloud-sdk 
fi
