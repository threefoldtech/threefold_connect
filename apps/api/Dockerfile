FROM node:18.12.1-alpine3.16 as builder

WORKDIR /app
RUN apk add --no-cache openssl1.1-compat
RUN apk add --no-cache libc6-compat
RUN yarn global add turbo
COPY . .
RUN yarn install --frozen-lockfile
RUN yarn run build --scope=api

FROM node:18.12.1-alpine3.16
USER root
RUN apk add --no-cache bash
RUN apk add --no-cache openssl1.1-compat
RUN apk add --no-cache libc6-compat

WORKDIR /app
COPY --from=builder /app/ /app/
RUN npm install pm2 prisma -g

RUN chmod +x /app/apps/api/start.sh
RUN chmod +x /app/apps/api/wait-for-it.sh
WORKDIR /app/apps/api
CMD ["./start.sh"]
