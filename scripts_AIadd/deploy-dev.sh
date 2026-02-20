#!/usr/bin/env bash
set -euo pipefail

# Dev deployment flow:
# 1) update develop
# 2) build binary
# 3) restart dev service

APP_DIR="${APP_DIR:-/srv/new-api/dev/current}"
BRANCH="${BRANCH:-develop}"
ENV_FILE="${ENV_FILE:-.env.dev}"
SERVICE_NAME="${SERVICE_NAME:-new-api-dev}"
BINARY_PATH="${BINARY_PATH:-${APP_DIR}/new-api-dev}"

cd "${APP_DIR}"

echo "==> Updating source: ${BRANCH}"
git fetch --all --prune
git checkout "${BRANCH}"
git pull --ff-only origin "${BRANCH}"

if [ ! -f "${ENV_FILE}" ]; then
  echo "Error: ${ENV_FILE} not found in ${APP_DIR}"
  exit 1
fi

echo "==> Building binary"
go build -o "${BINARY_PATH}" ./main.go

echo "==> Restarting service: ${SERVICE_NAME}"
sudo systemctl restart "${SERVICE_NAME}"
sudo systemctl status "${SERVICE_NAME}" --no-pager -n 20

echo "Dev deployment finished."
