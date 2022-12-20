## Backups inside pods

For backups, we use the Google Cloud SDK to push to the Google Console.

To provide daily backups inside a pod, both scripts are needed. 

`./init.sh` is needed on startup to append the cronjob inside the crontab.

See `redis.yaml` on how to execute a script on pod load.


`./init.sh` will insert a cronjob inside crontab, and the cronjob will execute `./backup.sh` each day to obtain backups.

## Prepare env

Since I couldn't find out yet on how to easily install the google cloud sdk inside a pod, we will use a PVC to store the Google Cloud SDK with its key
