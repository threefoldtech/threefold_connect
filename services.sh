#!/bin/bash
cd /usr/share/nginx/backend/

# Run Flask-SocketIO directly with gevent (bypass uWSGI for WebSocket support)
python3 -m backend &

nginx -g 'daemon off;'
