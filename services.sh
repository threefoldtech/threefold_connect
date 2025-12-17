#!/bin/sh
cd /usr/share/nginx/backend/ && uwsgi --http :5000 --gevent 1000 --http-websockets --gevent-monkey-patch --master --wsgi-file __main__.py --callable app &
nginx -g 'daemon off;'
