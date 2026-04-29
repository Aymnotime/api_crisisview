#!/usr/bin/env sh
set -eu

NAME="mysql-crisiview-test"

if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  docker rm -f "$NAME" >/dev/null
  echo "Test DB container removed"
else
  echo "Test DB container not found"
fi
