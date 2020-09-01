#!/usr/bin/env bash

set -e 

SERVICE_ACCOUNT="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email -H Metadata-Flavor:Google)"
[ -z "$SERVICE_ACCOUNT" ] && punt "couldn't detect service account"

PROJECT_ID="$(curl -s http://metadata.google.internal/computeMetadata/v1/project/project-id -H Metadata-Flavor:Google)"
[ -z "$PROJECT_ID" ] && punt "couldn't detect project id"


which docker || sudo apt-get install -y docker.io docker-compose
which gcloud || sudo apt-get install -y  google-cloud-sdk
sudo systemctl enable --now docker
sudo usermod -aG docker ${USER}
newgrp docker
if ! grep -q gcloud $HOME/.docker/config.json; then
  gcloud auth configure-docker --quiet --account $SERVICE_ACCOUNT --project $PROJECT_ID
fi
