#!/usr/bin/env sh
set -eu

NAME="mysql-crisiview-test"
IMAGE="mysql:8.4.8"
PORT="3307"
ROOT_PASSWORD="root"
DB_NAME="incident_db"

if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  docker rm -f "$NAME" >/dev/null 2>&1 || true
fi

NETWORK_OPT="-p ${PORT}:3306"
if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
  SELF_CONTAINER=$(cat /etc/hostname 2>/dev/null || echo "")
  if [ -n "$SELF_CONTAINER" ]; then
    NETWORK_OPT="--network container:${SELF_CONTAINER}"
  fi
fi

docker run -d --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="$ROOT_PASSWORD" \
  -e MYSQL_DATABASE="$DB_NAME" \
  $NETWORK_OPT \
  "$IMAGE" >/dev/null

until docker exec "$NAME" mysqladmin ping -h 127.0.0.1 -p"$ROOT_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 2
done

echo "Test DB ready on 127.0.0.1:${PORT}"
