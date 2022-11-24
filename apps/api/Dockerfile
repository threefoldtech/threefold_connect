FROM node:14-alpine as builder
WORKDIR /app
COPY . .
RUN yarn install --frozen-lockfile
RUN yarn run build --scope=api

FROM node:14-alpine
USER root
RUN apk add --no-cache bash
WORKDIR /app
COPY --from=builder /app/ /app/
RUN npm install pm2 prisma -g

RUN chmod +x /app/apps/api/start.sh
RUN chmod +x /app/apps/api/wait-for-it.sh
WORKDIR /app/apps/api
CMD ["./start.sh"]
