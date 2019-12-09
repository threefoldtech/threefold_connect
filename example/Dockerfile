FROM nginx:latest
COPY ./dist /usr/share/nginx/html
COPY example.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]