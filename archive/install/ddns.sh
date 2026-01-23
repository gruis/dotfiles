#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE}")";

. "./utils.sh" \
  && progress "${BASH_SOURCE}"

sudo cp ./ddns/gcp-ddns.sh /opt/
sudo cp ./ddns/gcpdns.service /etc/systemd/system/

sudo systemctl enable gcpdns.service

./google-cloud-sdk.sh
./ddns/gcp-ddns.sh
