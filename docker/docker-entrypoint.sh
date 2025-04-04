#!/bin/bash
# Check if STORAGE_DIR is set
if [ -z "$STORAGE_DIR" ]; then
    echo "================================================================"
    echo "⚠️  ⚠️  ⚠️  WARNING: STORAGE_DIR environment variable is not set! ⚠️  ⚠️  ⚠️"
    echo ""
    echo "Not setting this will result in data loss on container restart since"
    echo "the application will not have a persistent storage location."
    echo "It can also result in weird errors in various parts of the application."
    echo ""
    echo "Please run the container with the official docker command at"
    echo "https://docs.anythingllm.com/installation-docker/quickstart"
    echo ""
    echo "⚠️  ⚠️  ⚠️  WARNING: STORAGE_DIR environment variable is not set! ⚠️  ⚠️  ⚠️"
    echo "================================================================"
fi

if [ ! -z "${UID}" ]; then
  if [ ! "$(id -u anythingllm)" -eq "${UID}" ]; then
    usermod -o -u "${UID}" anythingllm
  fi
fi

if [ ! -z "${GID}" ]; then
  if [ ! "$(id -g anythingllm)" -eq "${GID}" ]; then
    groupmod -g "${GID}" anythingllm
  fi
fi

chown -R anythingllm:anythingllm /app
chown -R anythingllm:anythingllm "${STORAGE_DIR}"

gosu anythingllm bash -c "cd /app/server && npx prisma generate --schema=./prisma/schema.prisma && npx prisma migrate deploy --schema=./prisma/schema.prisma && node /app/server/index.js" &

gosu anythingllm bash -c "node /app/collector/index.js" &

wait -n
exit $?