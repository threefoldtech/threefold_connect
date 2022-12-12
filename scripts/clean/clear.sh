#!/bin/bash

ENV=beta
BETA_POD=beta-login-database-775d4789bc-gjs8c

rm ~/.kube/config
cp ~/.kube/config-hagrid-dev-jimber ~/.kube/config

kubectl exec $BETA_POD -n jimber -- sh -c "mysql --host=localhost --password=PASSWORD --user=root --execute='use beta-database; SET FOREIGN_KEY_CHECKS=0; delete from User where 1=1; delete from DigitalTwin;'"




