#!/bin/bash

if [ "$DB_MIGRATIONS_DISABLED" == "true" ]; then
    echo "DB migrations are disabled, skipping"
else
    echo "Running DB migrations"
    node ./db/migrations/"$DB_DIALECT"/migrate.cjs ./db/migrations/"$DB_DIALECT"
fi

AUTH_SECRET=$(openssl rand -base64 32)
export AUTH_SECRET

nginx -g 'daemon off;' &

redis-server /app/redis.conf &

node apps/tasks/tasks.cjs &

node apps/websocket/wssServer.cjs &

node apps/nextjs/server.js &

exec tail -f /dev/null
