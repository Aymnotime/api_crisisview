#!/usr/bin/env sh
set -eu

NAME="mysql-crisiview-test"
IMAGE="mysql:8.4.8"
PORT="3307"
ROOT_PASSWORD="root"
DB_NAME="incident_db"

# Cleanup if an old container exists
if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  docker rm -f "$NAME" >/dev/null 2>&1 || true
fi

docker run -d --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="$ROOT_PASSWORD" \
  -e MYSQL_DATABASE="$DB_NAME" \
  -p "${PORT}:3306" \
  "$IMAGE" >/dev/null

# Wait until MySQL is ready
until docker exec "$NAME" mysqladmin ping -h 127.0.0.1 -p"$ROOT_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 2
done

echo "Test DB ready on 127.0.0.1:${PORT}"
