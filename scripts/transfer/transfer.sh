#/bin/bash

rm ~/.kube/config
cp ~/.kube/config-hagrid-prod-jimber ~/.kube/config

kubectl cp  threebotlogin-prod-6957796896-dk5mn:persistantVolume/db/pythonsqlite.db pythonsqlite.db -c threebotlogin-prod -n jimber

rm ~/.kube/config
cp ~/.kube/config-hagrid-dev-jimber ~/.kube/config

kubectl cp pythonsqlite.db beta-login-database-775d4789bc-gjs8c:pythonsqlite.db -c beta-login-database -n jimber
kubectl cp ../migration/sqlite-to-mysql.py beta-login-database-775d4789bc-gjs8c:sqlite-to-mysql.py -c beta-login-database -n jimber
kubectl cp ../migration/requirements.txt beta-login-database-775d4789bc-gjs8c:requirements.txt -c beta-login-database -n jimber

kubectl exec beta-login-database-775d4789bc-gjs8c -n jimber -- sh -c "apt update -y && apt install python3 python3-pip -y && pip3 install -r requirements.txt && python3 --version"

kubectl exec beta-login-database-775d4789bc-gjs8c -n jimber -- sh -c "python3 sqlite-to-mysql.py"
