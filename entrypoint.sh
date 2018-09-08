#!/bin/sh

## Do whatever you need with env vars here ...
sed -i -e 's/host.port = 3000/host.port = '"$PORT"'/g' /myapp/conf/artanis.conf

# Hand off to the CMD
exec "$@"
