#!/usr/bin/env bash

set -e 

[[ -f  $HOME/.dotfiles.env ]] && source $HOME/.dotfiles.env

punt () {
  echo $1;
  exit 1;
}


if [ -z "$SERVICE_ACCOUNT" ]; then
  SERVICE_ACCOUNT="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email -H Metadata-Flavor:Google)"
  [ -z "$SERVICE_ACCOUNT" ] && punt "couldn't detect service account"
fi

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID="$(curl -s http://metadata.google.internal/computeMetadata/v1/project/project-id -H Metadata-Flavor:Google)"
  [ -z "$PROJECT_ID" ] && punt "couldn't detect project id"
fi

cd "$(dirname "${BASH_SOURCE}")";
./google-cloud-sdk.sh

if [ ! -f "/usr/bin/kubectl" ]; then
  sudo apt-get -y install kubectl
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
