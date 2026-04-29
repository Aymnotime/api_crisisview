#!/usr/bin/env sh
set -eu

NAME="mysql-crisiview-test"
IMAGE="mysql:8.4.8"
PORT="3306"
ROOT_PASSWORD="root"
DB_NAME="incident_db"

if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  docker rm -f "$NAME" >/dev/null 2>&1 || true
fi

AGENT_CONTAINER=$(cat /proc/self/cgroup 2>/dev/null | grep -oE '[0-9a-f]{64}' | head -1 || echo "")

if [ -n "$AGENT_CONTAINER" ]; then
  docker run -d --name "$NAME" \
    -e MYSQL_ROOT_PASSWORD="$ROOT_PASSWORD" \
    -e MYSQL_DATABASE="$DB_NAME" \
    --network "container:${AGENT_CONTAINER}" \
    "$IMAGE" >/dev/null
else
  PORT="3307"
  docker run -d --name "$NAME" \
    -e MYSQL_ROOT_PASSWORD="$ROOT_PASSWORD" \
    -e MYSQL_DATABASE="$DB_NAME" \
    -p "${PORT}:3306" \
    "$IMAGE" >/dev/null
fi

until docker exec "$NAME" mysqladmin ping -h 127.0.0.1 -p"$ROOT_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 2
done

echo "Test DB ready on 127.0.0.1:${PORT}"
