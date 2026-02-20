#!/usr/bin/env bash
set -euo pipefail

# Production deployment flow:
# 1) backup database
# 2) update main
# 3) build binary
# 4) restart prod service
# 5) run health check

APP_DIR="${APP_DIR:-/srv/new-api/prod/current}"
BRANCH="${BRANCH:-main}"
ENV_FILE="${ENV_FILE:-.env.prod}"
SERVICE_NAME="${SERVICE_NAME:-new-api-prod}"
BINARY_PATH="${BINARY_PATH:-${APP_DIR}/new-api-prod}"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:3000/api/status}"
BACKUP_CMD="${BACKUP_CMD:-echo 'Please override BACKUP_CMD for your DB backup'}"

cd "${APP_DIR}"

echo "==> Database backup"
eval "${BACKUP_CMD}"

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
sleep 2

echo "==> Health check: ${HEALTH_URL}"
if ! curl -fsS "${HEALTH_URL}" >/dev/null; then
  echo "Health check failed. Please rollback immediately."
  exit 2
fi

echo "Production deployment finished."
