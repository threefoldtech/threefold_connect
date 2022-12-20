FROM node:18-alpine as builder
RUN apk add --no-cache libc6-compat
RUN apk add --update --no-cache openssl1.1-compat
WORKDIR /app
RUN yarn global add turbo
COPY . .
RUN yarn install --frozen-lockfile
RUN yarn run build --scope=api

FROM node:18-alpine
USER root
RUN apk add --no-cache bash
WORKDIR /app
COPY --from=builder /app/ /app/
RUN npm install pm2 prisma -g

RUN chmod +x /app/apps/api/start.sh
RUN chmod +x /app/apps/api/wait-for-it.sh
WORKDIR /app/apps/api
CMD ["./start.sh"]
