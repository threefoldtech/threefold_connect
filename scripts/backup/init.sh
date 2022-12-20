#!/bin/bash

apt update && apt install python3 cron nano curl -y

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-412.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-412.0.0-linux-x86_64.tar.gz

CLOUDSDK_CORE_DISABLE_PROMPTS=1 ./google-cloud-sdk/install.sh --path-update true --command-completion true

source ~/.bashrc

gcloud auth activate-service-account --key-file google-cloud-key.json
chmod 741 /data/backup.sh

command="/data/backup.sh > /data/logging.txt  2>&1 or &"
job="0 1 * * * $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

service cron start
