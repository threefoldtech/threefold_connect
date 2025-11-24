FROM node:16-bullseye as builder
RUN apt-get update && \
    apt-get install -y build-essential python3 make gcc g++ curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json package.json
COPY yarn.lock yarn.lock
RUN yarn install --ignore-engines
COPY . .
RUN yarn build


FROM nginx:alpine as server
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
