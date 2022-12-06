## Development UI + API

**Start necessary docker containers**

```shell
docker-compose -f docker-compose.development.yml up -d
```

**Run shared types**

```shell
cd packages/shared-types && yarn build:watch
```

**Run migrations**

```shell
cd apps/api/ && yarn prisma:migrate-prod
```

**Start application**

```shell
yarn && yarn dev
```


## Development Mobile

Make sure you have at least ```Flutter 3.0.0``` properly installed. 

Change the configuration of your local development environment in the following file: ```mobile/lib/core/config/classes/config.local.dart```

Execute the following command to achieve the local configs: ```./build.sh --switch --local```

Connect your phone, enable USB-debugging and you are good to go. (Make sure to use the network IP configs and not localhost)





## Helm

The HELM stack currently has 3 main charts: frontend, development and database.

For ```development```, you can access the dev cluster from ThreeFold to deploy your pods.

Make sure you have the following files in your .kube folder:

- jimber-dev.crt
- jimber-dev.key
- config

Execute the following command to deploy to the cluster:

```shell
helm install dev helm_charts -f helm_charts/values/values-dev.yaml --set global.FRONTEND_IMAGE="ghcr.io/threefoldtech/threefold_connect/frontend:staging-latest" 
--set global.BACKEND_IMAGE="ghcr.io/threefoldtech/threefold_connect/backend:staging-latest" --set global.FLAGSMITH_API_KEY="T3vCeteoyrXNw82VGErnEL" 
--set global.DATABASE_URL="mysql://root:jimber@dev-database:3306/dev-database?schema=public" --set global.DOCKER_USERNAME="INSERT_DOCKER_USERNAME" 
--set global.DOCKER_REGISTRY="ghcr.io"  --set global.DOCKER_PASSWORD="INSERT_DOCKER_PASSWORD" --set global.DATABASE_PASSWORD="jimber" -n jimber 
```
