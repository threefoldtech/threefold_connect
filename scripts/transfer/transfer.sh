#!/bin/bash

ENV=beta
BETA_POD=beta-login-database-775d4789bc-gjljc
PROD_POD=threebotlogin-prod-6957796896-dk5mn

rm ~/.kube/config
cp ~/.kube/config-hagrid-prod-jimber ~/.kube/config

kubectl cp  $PROD_POD:persistantVolume/db/pythonsqlite.db pythonsqlite.db -c threebotlogin-prod -n jimber

rm ~/.kube/config
cp ~/.kube/config-hagrid-dev-jimber ~/.kube/config

kubectl cp pythonsqlite.db $BETA_POD:pythonsqlite.db -c $ENV-login-database -n jimber
kubectl cp ../migration/sqlite-to-mysql.py $BETA_POD:sqlite-to-mysql.py -c $ENV-login-database -n jimber
kubectl cp ../migration/requirements.txt $BETA_POD:requirements.txt -c $ENV-login-database -n jimber

if [[ $1 == "--init" ]]
then
 kubectl exec $BETA_POD -n jimber -- sh -c "apt update -y && apt install python3 python3-pip -y && pip3 install -r requirements.txt && python3 --version"
fi


kubectl exec $BETA_POD -n jimber -- sh -c "python3 sqlite-to-mysql.py --password=PASSWORD"
