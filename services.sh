cd /usr/share/nginx/backend/ && uwsgi --http :5000 --http-websockets --master --wsgi-file __main__.py --callable app &
nginx -g 'daemon off;'
