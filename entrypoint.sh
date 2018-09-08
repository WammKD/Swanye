#!/bin/sh

## Do whatever you need with env vars here ...
sed -i -e 's/listen       80;/listen       '"$PORT"';/g' /etc/nginx/conf.d/default.conf

/usr/sbin/nginx

# Hand off to the CMD
exec "$@"
