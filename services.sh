#!/bin/bash
cd /usr/share/nginx/backend/

# Start uWSGI with socket (not HTTP) for nginx uwsgi_pass
uwsgi --socket 127.0.0.1:5000 \
      --protocol uwsgi \
      --gevent 1000 \
      --gevent-monkey-patch \
      --master \
      --wsgi-file __main__.py \
      --callable app \
      --processes 1 \
      --threads 1 \
      --buffer-size 32768 \
      --lazy-apps &

nginx -g 'daemon off;'
