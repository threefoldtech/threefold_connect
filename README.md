# ThreeFold Connect

### Development

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
