#!/bin/bash

source ~/.bashrc


/data/google-cloud-sdk/bin/gsutil cp /data/dump.rdb gs://jimber_backups/pkid_redis_beta_backup/pkid_redis_backup-$(date +\%Y\%m\%d\%H\%M\%S).rdb

echo $(date)
echo "Backup done"
