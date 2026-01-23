#!/bin/bash

set -e

punt () {
  echo $1;
  exit 1;
}

cd "$(dirname "${BASH_SOURCE}")"  \
  && . "../utils.sh" \
  && progress "${BASH_SOURCE}"

DOMAIN_ID="devbox-aukai-io"
DOMAIN="devbox.aukai.io"

NAME="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/name -H Metadata-Flavor:Google | sed s/-devbox//)"
[ -z "$NAME" ] && punt "couldn't detect name"
RECORD_NAME="$NAME.$DOMAIN"

EXTERNAL_IP="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H Metadata-Flavor:Google)"
[ -z "$EXTERNAL_IP" ] && punt "couldn't detect external ip"
EXISTING=$(gcloud dns record-sets list --zone="$DOMAIN_ID" | grep $RECORD_NAME | awk '{print $4}')

if [ "$EXISTING" == "$EXTERNAL_IP" ]; then
  echo "DNS already registered";
else
  gcloud dns record-sets transaction start -z=$DOMAIN_ID

  if [ ! -z "$EXISTING" ]; then
    echo "removing existing record $RECORD_NAME: $EXISTING";
    gcloud dns record-sets transaction remove -z=$DOMAIN_ID \
        --name="$RECORD_NAME." \
        --type=A \
        --ttl=300 "$EXISTING";
  fi

  echo "adding $RECORD_NAME: $EXTERNAL_IP";
  gcloud dns record-sets transaction add -z=$DOMAIN_ID \
     --name="$RECORD_NAME." \
     --type=A \
     --ttl=300 "$EXTERNAL_IP";

  gcloud dns record-sets transaction execute -z=$DOMAIN_ID
fi
