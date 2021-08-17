cd /usr/share/nginx/backend/ && uwsgi --disable-logging --http :5000 --gevent 1000 --http-websockets --master --wsgi-file __main__.py --callable app -s 0.0.0.0:3030 -b 23000 &
nginx -g 'daemon off;
