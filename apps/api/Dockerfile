FROM node:18.12.1-alpine3.17 as builder

WORKDIR /app
RUN apk update && apk add openssl1.1-compat

COPY . .
RUN yarn install --frozen-lockfile
RUN yarn run build --scope=api

FROM node:18.12.1-alpine3.17
USER root
RUN apk update && apk add openssl1.1-compat
RUN apk add --no-cache bash

WORKDIR /app
COPY --from=builder /app/ /app/
RUN npm install pm2 prisma -g

RUN chmod +x /app/apps/api/start.sh
RUN chmod +x /app/apps/api/wait-for-it.sh
WORKDIR /app/apps/api
CMD ["./start.sh"]
