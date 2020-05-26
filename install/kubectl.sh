#!/usr/bin/env bash

set -e 

punt () {
  echo $1;
  exit 1;
}


SERVICE_ACCOUNT="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email -H Metadata-Flavor:Google)"
[ -z "$SERVICE_ACCOUNT" ] && punt "couldn't detect service account"

PROJECT_ID="$(curl -s http://metadata.google.internal/computeMetadata/v1/project/project-id -H Metadata-Flavor:Google)"
[ -z "$PROJECT_ID" ] && punt "couldn't detect project id"

if [ ! -f "/etc/apt/sources.list.d/google-cloud-sdk.list" ]; then
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
fi
which gpg || sudo apt-get -y install apt-transport-https ca-certificates gnupg
[[ -f "/usr/share/keyrings/cloud.google.gpg" ]]  || curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
if [ ! -f "/usr/bin/kubectl" ]; then
  sudo apt-get update && sudo apt-get -y install google-cloud-sdk kubectl
fi

[[ -d $HOME/.config/gcloud ]] || yes "n" | gcloud init --console-only --account $SERVICE_ACCOUNT --project $PROJECT_ID

while IFS= read -r line; do
  name="$(echo $line | awk '{print $1}')"
  if [ ! "$name" == "NAME" ]; then
    if ! kubectl config get-contexts | grep -q "$name"; then
      echo "adding $name context"
      location="$(echo $line | awk '{print $2}')"
      count=`awk -F"-" '{print NF-1}' <<< "$location"`
      if [ $count -eq 2 ]; then
        gcloud container clusters get-credentials $name --zone $location
      else
        if [ $count -eq 1 ]; then
          gcloud container clusters get-credentials $name --region $location
        else
          punt "can't determine if location is a zone or region"
        fi
      fi
    fi
  fi
done <<< "$(gcloud container clusters list)"
